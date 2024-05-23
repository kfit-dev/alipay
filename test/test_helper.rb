require 'minitest/autorun'
require 'alipay'
require 'webmock/minitest'

Alipay.pid = '1000000000000000'
Alipay.key = '10000000000000000000000000000000'
Alipay.legacy_gateway_url = 'https://api-sea-global.alipayplus.com'

STUB_URL_REGEX = %r{https://api-sea-global\.alipayplus\.com/gateway\.do.*}.freeze

TEST_RSA_PUBLIC_KEY = <<EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCjNVhJf9PYDFN1PFd4SXEvxmjD
0dn+xQ4lQu6o8HbGXz4de/RRVTJDL48qwxn81lar5cNSIjbnhDRXm9fZcrzuwbjq
xXOv2Ov7MZAa/WJEcfvp3XcSgxKPB54FLVvHo/rxuMK2xpps47Lpc7vppkvi3ofb
XW61S+aT0TWFkUMTnwIDAQAB
-----END PUBLIC KEY-----
EOF

TEST_RSA_PRIVATE_KEY = <<EOF
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKM1WEl/09gMU3U8
V3hJcS/GaMPR2f7FDiVC7qjwdsZfPh179FFVMkMvjyrDGfzWVqvlw1IiNueENFeb
19lyvO7BuOrFc6/Y6/sxkBr9YkRx++nddxKDEo8HngUtW8ej+vG4wrbGmmzjsulz
u+mmS+Leh9tdbrVL5pPRNYWRQxOfAgMBAAECgYB7xOSjOJFK8m4IJi6fRfLULD8e
4XHUR1Qm5c9fxpwMbAYLDgmF9HodgV+tKi/3EgTAb4nkK5Y/lH6tQb47ZUvo/lKz
RlIVZ6Rm76V07g/+5exIZzTyvdD9T2fLeYQwKV/2JYUv0KSYWPvWykdaV4aNkCuw
mxTUjvhDxK/Ns31CIQJBANI1Y3gGBqbBIN9wxjx3ShBtt/U8YnipUJ92eTI7OU9p
ZsCIFPoeYG/X40miwDb5ouPnvJTtzuY4PkPokEefN9MCQQDGwurqa8RNK2APA62U
CdZbJuWimkdHEc53IKvD/l2tWVFqhVAy8bs+3LGzBNfuxUuAxOoQm9n0IVRaH5jn
l8GFAkEAijuTmsUTsKsGDAmkQvULHnyYYUuBUem92+9TycWKbX9Zk7ipWsWJE2N7
0tuU3VISXR7yM1mjGl/YCl4wKvk4AwJAE1DkBY4dkKZTeoIP/2AJXehkzq2Rmb2I
RBl/t9djgTI58FEuXxUQ7mYCOvSQi5rO4J/CY4TR5KDMksmZUYB1BQJAIEfVDxz4
5yoHL7L+6EoC5TWxUxFMN7z7FhObyKeaLKj3inEsbjfcPCA09zPUce0FSKBc/dVh
DEorJMaPK5vXiA==
-----END PRIVATE KEY-----
EOF

TEST_APP_CERT = <<EOF
-----BEGIN CERTIFICATE-----
MIICgjCCAeugAwIBAgIBADANBgkqhkiG9w0BAQUFADA6MQswCQYDVQQGEwJCRTEN
MAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVzdDENMAsGA1UEAwwEVGVzdDAeFw0x
OTA5MDkwNDA2MDRaFw0yMDA5MDgwNDA2MDRaMDoxCzAJBgNVBAYTAkJFMQ0wCwYD
VQQKDARUZXN0MQ0wCwYDVQQLDARUZXN0MQ0wCwYDVQQDDARUZXN0MIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQDf2XVQvEYTpzRLdq+ya1OYBU3Eh6k1GBAcTLpA
9XRyx13Aio6gcx0HQuGPtzXzvPP1Nj2c7TNfzrmQlybLz4yFvK36kqz3gzi7puEI
7pQByWAr+jCdi28Zq60QnX5dxeBqF8RF1nSNH/6utZMBaiG4xxo43Bw6NCt4RFlv
F15CVwIDAQABo4GXMIGUMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFP35+qaf
lXuPOqsy0La/xpBtzhftMGIGA1UdIwRbMFmAFP35+qaflXuPOqsy0La/xpBtzhft
oT6kPDA6MQswCQYDVQQGEwJCRTENMAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVz
dDENMAsGA1UEAwwEVGVzdIIBADANBgkqhkiG9w0BAQUFAAOBgQAl6Fqvyi25+lPY
XaVsCdJFSmphWGQrJHx3KxcJxzqtTahCxuBtmFx2MNg4jUIKYTZCq5l0ZpmjgA3s
pJHval/EZ1IJ2ch3/EULWd0lzk5HnSkiCPlWe1DQSKxM+FOzSEBtZl2ZKGznXYk5
+TnZ6yvJ4j4PIdSrpebOKyzXsur9ZQ==
-----END CERTIFICATE-----
EOF

TEST_ALIPAY_ROOT_CERT = <<EOF
-----BEGIN CERTIFICATE-----
MIICgjCCAeugAwIBAgIBADANBgkqhkiG9w0BAQUFADA6MQswCQYDVQQGEwJCRTEN
MAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVzdDENMAsGA1UEAwwEVGVzdDAeFw0x
OTA5MDkwNDA2MDRaFw0yMDA5MDgwNDA2MDRaMDoxCzAJBgNVBAYTAkJFMQ0wCwYD
VQQKDARUZXN0MQ0wCwYDVQQLDARUZXN0MQ0wCwYDVQQDDARUZXN0MIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQDf2XVQvEYTpzRLdq+ya1OYBU3Eh6k1GBAcTLpA
9XRyx13Aio6gcx0HQuGPtzXzvPP1Nj2c7TNfzrmQlybLz4yFvK36kqz3gzi7puEI
7pQByWAr+jCdi28Zq60QnX5dxeBqF8RF1nSNH/6utZMBaiG4xxo43Bw6NCt4RFlv
F15CVwIDAQABo4GXMIGUMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFP35+qaf
lXuPOqsy0La/xpBtzhftMGIGA1UdIwRbMFmAFP35+qaflXuPOqsy0La/xpBtzhft
oT6kPDA6MQswCQYDVQQGEwJCRTENMAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVz
dDENMAsGA1UEAwwEVGVzdIIBADANBgkqhkiG9w0BAQUFAAOBgQAl6Fqvyi25+lPY
XaVsCdJFSmphWGQrJHx3KxcJxzqtTahCxuBtmFx2MNg4jUIKYTZCq5l0ZpmjgA3s
pJHval/EZ1IJ2ch3/EULWd0lzk5HnSkiCPlWe1DQSKxM+FOzSEBtZl2ZKGznXYk5
+TnZ6yvJ4j4PIdSrpebOKyzXsur9ZQ==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIICgjCCAeugAwIBAgIBADANBgkqhkiG9w0BAQUFADA6MQswCQYDVQQGEwJCRTEN
MAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVzdDENMAsGA1UEAwwEVGVzdDAeFw0x
OTA5MDkwNDA2MDRaFw0yMDA5MDgwNDA2MDRaMDoxCzAJBgNVBAYTAkJFMQ0wCwYD
VQQKDARUZXN0MQ0wCwYDVQQLDARUZXN0MQ0wCwYDVQQDDARUZXN0MIGfMA0GCSqG
SIb3DQEBAQUAA4GNADCBiQKBgQDf2XVQvEYTpzRLdq+ya1OYBU3Eh6k1GBAcTLpA
9XRyx13Aio6gcx0HQuGPtzXzvPP1Nj2c7TNfzrmQlybLz4yFvK36kqz3gzi7puEI
7pQByWAr+jCdi28Zq60QnX5dxeBqF8RF1nSNH/6utZMBaiG4xxo43Bw6NCt4RFlv
F15CVwIDAQABo4GXMIGUMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFP35+qaf
lXuPOqsy0La/xpBtzhftMGIGA1UdIwRbMFmAFP35+qaflXuPOqsy0La/xpBtzhft
oT6kPDA6MQswCQYDVQQGEwJCRTENMAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVz
dDENMAsGA1UEAwwEVGVzdIIBADANBgkqhkiG9w0BAQUFAAOBgQAl6Fqvyi25+lPY
XaVsCdJFSmphWGQrJHx3KxcJxzqtTahCxuBtmFx2MNg4jUIKYTZCq5l0ZpmjgA3s
pJHval/EZ1IJ2ch3/EULWd0lzk5HnSkiCPlWe1DQSKxM+FOzSEBtZl2ZKGznXYk5
+TnZ6yvJ4j4PIdSrpebOKyzXsur9ZQ==
-----END CERTIFICATE-----
EOF
