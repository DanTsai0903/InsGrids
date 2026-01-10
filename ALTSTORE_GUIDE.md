# How to Install InsGrids with AltStore (Free, Wireless Renewal)

This guide will teach you how to use [AltStore](https://altstore.io/) to install InsGrids on your iPhone. This is currently the most stable and free installation method.

## Phase 1: Computer Preparation

### 1. Install AltServer
1. Go to [altstore.io](https://altstore.io/) and download **AltServer (macOS)**.
2. Unzip and drag `AltServer.app` into your "Applications" folder.
3. Open AltServer (it will appear in the menu bar).

### 2. Install Mail Plug-in (Required)
1. Click the AltServer icon in the menu bar > **Install Mail Plug-in**.
2. Open the "Mail" app on your Mac.
3. Mail > Settings > General > Manage Plug-ins...
4. Check **AltPlugin.mailbundle** and click "Allow Access".
5. Restart the Mail app.

### 3. Generate App File
We have prepared an automatic packaging script for you. Just run in the terminal:

```bash
./generate_ipa.sh
```

After execution, an `InsGrids.ipa` file will appear in the folder. This is the package we want to install.

## Phase 2: Phone Installation

### 1. Install AltStore on Phone
1. Connect your iPhone to your Mac via USB cable.
2. Click the AltServer icon in the menu bar > **Install AltStore** > Select your iPhone.
3. Enter your Apple ID and password (this is only used to request a free certificate from Apple, it is safe).
4. After a few seconds, the AltStore app will appear on your iPhone.

### 2. Trust Developer
1. On your iPhone, go to **Settings > General > VPN & Device Management**.
2. Tap your Apple ID.
3. Tap "Trust...".

## Phase 3: Install InsGrids

1. **Transfer File**: Transfer the `InsGrids.ipa` just generated on your computer to your iPhone via AirDrop.
2. **Install**:
   - Open AltStore on your iPhone.
   - Tap **My Apps** at the bottom.
   - Tap the **+** button in the top left corner.
   - Select the `InsGrids.ipa` you just transferred.
   - If this is your first time using it, you may need to enter your Apple ID again.
3. **Done!** InsGrids is now installed on your phone and ready to use.

## How to Keep the App Active?

Apps on free accounts only have a 7-day validity period. However, AltStore will automatically renew it for you:
1. Ensure **AltServer** is running on your computer.
2. Ensure your iPhone and computer are connected to the **same Wi-Fi**.
3. AltStore will automatically refresh the signature in the background (you can open AltStore at any time to check the remaining days).

As long as your phone and computer meet on the same Wi-Fi once every 7 days, your app can be used permanently!

## How to Update the App?

When InsGrids has new features or bug fixes, updating is very simple:

1. **Regenerate File**:
   - Re-run the packaging script on your computer:
     ```bash
     ./generate_ipa.sh
     ```
   - This will generate the latest `InsGrids.ipa`.

2. **Overwrite Install**:
   - Transfer the new IPA to your phone.
   - Open it again with AltStore.
   - AltStore will automatically overwrite the old version, and your settings and data will usually be preserved.

**Note**: You do not need to delete the old version of the app, just install the new version to overwrite it.
