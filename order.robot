*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             Dialogs
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Archive
Library             RPA.Robocorp.Vault
Library             OperatingSystem


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the file
    ${orders}=    Get orders
    Open the Robot Order Website
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Download the file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Open the Robot Order Website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${sale}
    Select From List By Value    head    ${sale}[Head]
    Click Element    id:id-body-${sale}[Body]
    Input Text    //form/div[3]/input    ${sale}[Legs]
    Input Text    address    ${sale}[Address]

Preview the robot
    Click Button    Preview

Submit the order
    Click Button    Order

Store the receipt as a PDF file
    [Arguments]    ${ordernumber}
    Wait Until Element Is Visible    id:receipt
    ${results_html}=    Get Element Attribute    id:receipt    innerHTML
    Html To Pdf    ${results_html}    ${OUTPUT_DIR}${/}order-${ordernumber}.pdf
    RETURN    ${OUTPUT_DIR}${/}order-${ordernumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${ordernumber}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}order-${ordernumber}.png
    RETURN    ${OUTPUT_DIR}${/}order-${ordernumber}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf
    Remove File    ${screenshot}

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    Receipts.zip
