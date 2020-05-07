# DKIM/SPF/Reverse IP Check
send test email to check-auth@verifier.port25.com

`echo "test email" | s-nail -s "Test email" -r contact@attestation.app check-auth@verifier.port25.com`

# Opportunistic DANE
send test email to havedane.net and check the website

Make sure that host has DNS resolver that supports DNSSEC verification.
