# Tofu

An easy-to-use, open-source two-factor authentication app designed specifically
for iOS.

Tofu generates one-time passwords to help you protect your online accounts.
These passwords are used together with your normal password when you sign into
services like Google, Facebook, Dropbox, Amazon, and GitHub.

Tofu works with all services that provide two-factor authentication using the
HOTP and TOTP algorithms. It does not require a network or cellular connection
and can be used in airplane mode.

## Installation

Tofu is available for free on the App Store.

[![Download on the App Store](https://tofuauth.com/images/app-store.svg)](https://itunes.apple.com/app/tofu-authenticator/id1082229305)

## Issuer icons

Here's how you can help add new icons to the app:

1. Fork and clone this repo.

2. Add your icon to the `IssuerIcons/` directory.

   The icon should be a square PNG without rounded corners and without borders.
   It must be at least 196x196 pixels but we prefer larger sizes such as
   1024x1024.

3. Run `./GenerateIssuerIconAssets.sh` from the root of the repo.

4. Add an entry for the icon to [the `imageNames` dictionary](https://github.com/calleerlandsson/Tofu/blob/master/Tofu/AccountCell.swift#L15).

   The key should be the string that shows up in the Issue field when scanning
   a QR code for the service. The value should be the name of the icon file.

5. Commit your work and open a PR.

Here's an example commit for adding a new icon:
https://github.com/calleerlandsson/Tofu/commit/692e32a9744bcaa360e4d7db9f00c4e90f6f66ac

If you don't feel comfortable adding icons yourself, you can ask that someone
else does so by [opening an issue using the issuer icon request template](https://github.com/calleerlandsson/Tofu/issues/new?labels=icon+request&template=issuer-icon-request.md&title=Add+an+icon+for+Example).

## Sponsors

The ongoing development of Tofu is made possible by the support of our generous sponsors:

[![Corporate Trust](https://user-images.githubusercontent.com/66666/100761071-c11df400-33f2-11eb-9c81-962e9107f93c.png)](https://www.corporate-trust.de/en/)
