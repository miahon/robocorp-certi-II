*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.Desktop
Library           RPA.Archive
Library           RPA.Images

*** Variables ***
${CSV_FILE_NAME}=     orders.csv
${CSV_FILE_URL}=      https://robotsparebinindustries.com/${CSV_FILE_NAME}
${ORDER_URL}=       https://robotsparebinindustries.com/#/robot-order


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    10X    2s    Click Button    Preview
        #Wait Until Page Contains Element    id:robot-preview-image
        Make order                
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Click Button    Order another robot    
    END
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}receipts.zip   append=True    include=*.pdf
    [Teardown]    Close Browser


*** Keywords ***
Open the order website
    Open Available Browser    ${ORDER_URL}
 
Close the annoying modal
    Click Button    OK
    #Click Button    css:Button[class="btn btn-dark"] 

Get orders
    Download    ${CSV_FILE_URL}  overwrite=True
    ${table}=    Read table from CSV    ${CSV_FILE_NAME}
    RETURN        ${table}


Fill the form
    [Arguments]    ${orders}
    Select From List By Value    head    ${orders}[Head]
    Select Radio Button    body    ${orders}[Body]
    Input Text    address    ${orders}[Address]
    Input Text    css:Input[placeholder="Enter the part number for the legs"]    ${orders}[Legs]

Make order
    Wait Until Keyword Succeeds    10X    2s    Click Button    Order
    Check Element Visible


Check Element Visible
    ${element_visible} =    Run Keyword And Return Status    Element Should Be Visible    id:receipt
    Run Keyword If    '${element_visible}' == 'False'    Make Order


Store the receipt as a PDF file  
    [Arguments]    ${order_number}
    ${receipt_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}${order_number}.pdf
    RETURN         ${OUTPUT_DIR}${/}${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    css:div#robot-preview-image   ${OUTPUT_DIR}${/}${order_number}.png
    RETURN    ${OUTPUT_DIR}${/}${order_number}.png
    
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf  ${pdf}
    ${pngToPDF}    Create List    ${screenshot}    
    Add Files To Pdf    ${pngToPDF}    ${pdf}    append=True
    Close Pdf  ${pdf}
    

   
    

 
     
    
    
    