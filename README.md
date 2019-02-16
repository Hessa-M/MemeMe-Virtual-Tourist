# MemeMe Virtual Tourist

The MemeMe Virtual Tourist is an app download and store photos Flickr depended on location. The app allowed users to delete pin or delete photo. The users Also can write to image and share it with friends.

## Implementation

The app has three view controller:

- **MapVieController** - shows the map and fetch the saved pin and save the new pin drop by users. Also, the users can delete the pin when presses the edit button. And the selected pin from users will send there data to the photo View Controller.

- **PhotoViewController** - Check if the pin has photos or download them using Flickr API. Can the users  download new photos and delete the photo when the  presses the edit button. And the selected photo from users will send the image to the Edit View Controller.

- **MemeEditorViewController** - allow users to write to image and share it with friends.

## Requirements
- Mac os
- Xcode 10
- Swift 4
