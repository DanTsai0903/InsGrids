# Spec: Duplicate Detection and Naming

## ADDED Requirements

#### Scenario: Importing a new sticker
Given a new sticker image "foo.svg"
When I run `sticker-importer import`
Then the tool calculates the pHash (Perceptual Hash) of "foo.svg" (converting to PNG if needed)
And checks against existing stickers in `CustomStickerCategory.swift`
And if no duplicate found (distance < 10)
Then it imports the sticker as "foo_{hash}"

#### Scenario: Duplicate sticker
Given an existing sticker "bar_{hash1}"
And a new sticker "foo.svg" which has hash "{hash2}" where distance(hash1, hash2) < 10
When I run `sticker-importer import`
Then the tool detects it as a duplicate
And skips the import
And logs a message "Duplicate found: foo.svg matches bar ({distance})"

#### Scenario: Naming with Hash
Given a sticker "icon.png" with hash "1234123412341234"
When I import it
Then the resulting name in `CustomStickerCategory.swift` is "icon_1234123412341234"
And the .imageset folder is named "icon_1234123412341234.imageset"

#### Scenario: Manual Labeling
Given stickers with empty labels in `CustomStickerCategory.swift`
When I run `sticker-importer label-stickers`
Then it finds the images for those stickers in `Assets.xcassets`
And calls Gemini API to generate labels
And updates `CustomStickerCategory.swift` with the new labels
