###############################################################################################################################################################################
###                                                                                                           																###
###		.INFORMATIONS																																						###
###  	Script by Drago Petrovic -                                                                            																###
###     Technical Blog -               https://msb365.abstergo.ch                                               															###
###     GitHub Repository -            https://github.com/MSB365                                          	  																###
###     Webpage -                                                                  																							###
###     Xing:				   		   https://www.xing.com/profile/Drago_Petrovic																							###
###     LinkedIn:					   https://www.linkedin.com/in/drago-petrovic-86075730																					###
###																																											###
###		.VERSION																																							###
###     Version 1.0 - 02/02/2017                                                                              																###
###     Version 2.0 - 22/06/2017                                                                              																###
###     Revision -                                                                                            																###
###                                                                                                           																### 
###               v1.0 - Initial script										                                  																###
###               v2.0 - Exchange 2016 supported                                          																					###
###																																											###
###																																											###
###		.SYNOPSIS																																							###
###		SetDAG.ps1																																							###
###																																											###
###		.DESCRIPTION																																						###
###		Create a new Exchange DAG with two Exchange servers as Member																										###
###																																											###
###		.PARAMETER																																							###
###																																											###
###																																											###
###		.EXAMPLE																																							###
###		.\MsCloudPsConnector.ps1																																			###
###																																											###
###		.NOTES																																								###
###		Ensure you update the script with your tenant name and username																										###
###		Your username is in the Exchange Online section for Get-Credential																									### 	
###		The tenant name is used in the Exchange Online section for Get-Credential																							###
###		The tenant name is used in the SharePoint Online section for SharePoint connection URL																				###
###                                                                                                           																###  	
###     .COPIRIGHT                                                            																								###
###		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 					###
###		to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 					###
###		and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:							###
###																																											###
###		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.										###
###																																											###
###		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 				###
###		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 		###
###		WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.			###
###                 																																						###
###                                                																															###
###     --- keep it simple, but significant ---                                                                                            									###
###                                                                                                           																###
###############################################################################################################################################################################
#
Write-Host "!!! with great power comes great responsibility !!!" -ForegroundColor magenta -Verbose
#
#####################################################################################################
# Variables
Write-Host "Enter the Informations witch are needed to create a DAG" -ForegroundColor yellow
$DAGName = Read-Host "Enter the Name, how you wanna name your DAG"
$Witness = Read-Host "Enter the Serverhostname for the WITNESS server e.g. srv00n"
$WitnessPath = Read-Host "Enter the Witness directory Path for the DAG on the Witness server e.g. C:\FSW\"
$EXC01 = Read-Host "Enter the Serverhostname for the 1st Exchange server, witch you wanna have as DAG Member e.g. srv01EX"
$EXC02 = Read-Host "Enter the Serverhostname for the 2nd Exchange server, witch you wanna have as DAG Member e.g. srv02EX"
#####################################################################################################
### Script
# Creating DAG
Write-Host "Creating DAG with the Name $DAGName" -ForegroundColor cyan
New-DatabaseAvailabilityGroup -Name $DAGName -WitnessServer $Witness -WitnessDirectory $WitnessPath+$DAGName 
Write-Host "Done!" -ForegroundColor green

# Adding Exchange servers
Write-Host "Adding $EXC01 to $DAGName ..." -ForegroundColor cyan
Add-DatabaseAvailabilityGroupServer -Identity $DAGName -MailboxServer $EXC01
Write-Host "Done!" -ForegroundColor green
Write-Host "Adding $EXC02 to $DAGName ..." -ForegroundColor cyan
Add-DatabaseAvailabilityGroupServer -Identity $DAGName -MailboxServer $EXC02
Write-Host "Done!" -ForegroundColor green

# Checking status
Write-Host "Checking DAG status..." -ForegroundColor cyan 
Get-DatabaseAvailabilityGroup $DAGName -Status
Get-DatabaseAvailabilityGroup $DAGName -Status | fl *witness* 
Write-Host "Done!" -ForegroundColor green

# Set DAC
Write-Host "Setting DAC (DatacenterActivationCoordination Mode) more infos about it: https://practical365.com/exchange-server/exchange-best-practices-datacenter-activation-coordination-mode/" -ForegroundColor cyan
Set-DatabaseAvailabilityGroup -Identity $DAGName -DatacenterActivationMode DagOnly
Write-Host "Done!" -ForegroundColor green

# Finishing
$path = $WitnessPath+$DAGName
Write-Host "The DAG: $DAGName was created with the Members: $EXC01 and $EXC02! Please check on the Witness server $Witness if the Path $path is successfully created!" -ForegroundColor magenta -Verbose