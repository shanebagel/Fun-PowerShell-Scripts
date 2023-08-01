Import-Module Microsoft.Graph.Users.Actions
$params = @{
	Message = @{
		Subject = "This is a test email"
		Body = @{
			ContentType = "Text"
			Content = "Howdy partner - this town ain't big enough for the two of us"
		}
		ToRecipients = @(
			@{
				EmailAddress = @{
					Address = "hartley.shane@outlook.com"
				}
			}
		)
		CcRecipients = @(
			@{
				EmailAddress = @{
					Address = "johan.ortiz@ecwcomputers.com"
				}
			}
		)
	}
	SaveToSentItems = "false"
}
# A UPN can also be used as -UserId.
Send-MgUserMail -UserId $userId -BodyParameter $params