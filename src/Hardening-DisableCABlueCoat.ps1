# See http://blogs.msmvps.com/alunj/2016/05/26/untrusting-the-blue-coat-intermediate-ca-from-windows/
#Invoke-WebRequest -Uri "https://crt.sh/?id=19538258" -OutFile "${env:temp}/Hardening-DisableCABlueCoat.crt"
$CABlueCoat = "${env:temp}\"+[System.IO.Path]::GetRandomFileName()+".cer"
@'
-----BEGIN CERTIFICATE-----
MIIGTDCCBTSgAwIBAgIQUWMOvf4tj/x5cQN2PXVSwzANBgkqhkiG9w0BAQsFADCB
yjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYDVQQLEzEoYykgMjAwNiBWZXJp
U2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVzZSBvbmx5MUUwQwYDVQQDEzxW
ZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRpb24gQXV0
aG9yaXR5IC0gRzUwHhcNMTUwOTI0MDAwMDAwWhcNMjUwOTIzMjM1OTU5WjCBhDEL
MAkGA1UEBhMCVVMxIDAeBgNVBAoTF0JsdWUgQ29hdCBTeXN0ZW1zLCBJbmMuMR8w
HQYDVQQLExZTeW1hbnRlYyBUcnVzdCBOZXR3b3JrMTIwMAYDVQQDEylCbHVlIENv
YXQgUHVibGljIFNlcnZpY2VzIEludGVybWVkaWF0ZSBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAJ/Go2aR50MoHttT0E7g9bDUUzKomaIkCRy5gI8A
BRkAed7v1mKUk/tn7pKxOvYHnd8BG3iT+eQ2P1ha2oB+vymj4b35gOAcYQIEEYCO
vH35pSqRKlmflrI5RwjX/+l9O+YUn2cK0uYeJBXNMfTse6/azxksNQjK1CFqFcWz
XIK12+THFiFQuuCc5lON6nkhpBkGJSCN43nevFigNhW3YWZG/Z1l86Y9Se0Sf96o
fL7VnV2Ri0kSwJuxNYH7ei5ZBG8GVuNFuqPhmfE2YD2yjbXMnnn4hKOWsM8Oe0xL
ocjPgMTGVgvgeqZo8tV2gvaAycPO4PcJ+yHlgXtdyV7qztECAwEAAaOCAnAwggJs
MBIGA1UdEwEB/wQIMAYBAf8CAQAwLwYDVR0fBCgwJjAkoCKgIIYeaHR0cDovL3Mu
c3ltY2IuY29tL3BjYTMtZzUuY3JsMA4GA1UdDwEB/wQEAwIBBjAuBggrBgEFBQcB
AQQiMCAwHgYIKwYBBQUHMAGGEmh0dHA6Ly9zLnN5bWNkLmNvbTCCAVkGA1UdIASC
AVAwggFMMFwGBmeBDAECAjBSMCYGCCsGAQUFBwIBFhpodHRwOi8vd3d3LnN5bWF1
dGguY29tL2NwczAoBggrBgEFBQcCAjAcGhpodHRwOi8vd3d3LnN5bWF1dGguY29t
L3JwYTB1BgorBgEEAfElBAIBMGcwZQYIKwYBBQUHAgIwWRpXSW4gdGhlIGV2ZW50
IHRoYXQgdGhlIEJsdWVDb2F0IENQUyBhbmQgU3ltYW50ZWMgQ1BTIGNvbmZsaWN0
LCB0aGUgU3ltYW50ZWMgQ1BTIGdvdmVybnMuMHUGCisGAQQB8SUEAgIwZzBlBggr
BgEFBQcCAjBZGldJbiB0aGUgZXZlbnQgdGhhdCB0aGUgQmx1ZUNvYXQgQ1BTIGFu
ZCBTeW1hbnRlYyBDUFMgY29uZmxpY3QsIHRoZSBTeW1hbnRlYyBDUFMgZ292ZXJu
cy4wHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMCkGA1UdEQQiMCCkHjAc
MRowGAYDVQQDExFTeW1hbnRlY1BLSS0yLTIxNDAdBgNVHQ4EFgQUR5UKC6ehgqJt
yZuczT7zkELkb5kwHwYDVR0jBBgwFoAUf9Nlp8Ld7LvwMAnzQzn6Aq8zMTMwDQYJ
KoZIhvcNAQELBQADggEBAJjsKAGzmIEavosNMHxJVCidIGF1r3+vmGBoSVU5iT9R
1DKnrQc8KO5l+LgMuyDUMmH5CxbLbOWT/GtEC/ZvyiVTfn2xNE9SXw46zNUz1oOO
DMJLyvTMuRt7LsExqqsg3KZo6esNW5gmCYbLyfcjn7dKbtjkHvOdxJJ7VrDDayeC
Z5rBgiTj1+l09Uxo+2rwfEvHXzVtWSQyuqxRc8DVwCgFGrnJNGJS1coOQdQ91i6Q
zij5S/djgP1rVHH+MkgJcUQ/2km9GC6B6Y3yMGq6XLVjLvi73Ch2G5mUWkeoZibb
yQSxTBWG6GJjyDY7543ZK3FH4Ctih/nFgXrjuY7Ghrk=
-----END CERTIFICATE-----
'@ > $CABlueCoat
Import-Certificate -Filepath $CABlueCoat -CertStoreLocation Cert:\LocalMachine\Disallowed | out-null
Remove-Item -Force $CABlueCoat -ErrorAction Ignore