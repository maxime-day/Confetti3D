# 🎉 Confetti3D

**Confetti3D** is a lightweight and customizable Swift package that allows you to easily add confetti effects to your iOS applications using **SwiftUI** or **UIKit**. Under the hood, it leverages **SceneKit** to provide smooth and efficient 3D confetti animations.

## ✨ Features

- 🎨 Fully customizable confetti shapes, colors, and behaviors  
- 🏎️ Optimized for performance using SceneKit  
- 📱 Works seamlessly with both SwiftUI and UIKit  
- 🛠️ Simple and easy-to-use API  
- 📡 **Interactive effects**: Confetti adapts to the device's **accelerometer**, reacting to movements for a more immersive experience  

| Confetti | Glitter |
|----------|----------|
| ![Confetti GIF](https://private-user-images.githubusercontent.com/29275033/436479167-0fdd560e-e04b-437f-a948-1c76a59526e4.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDU0MDM0OTMsIm5iZiI6MTc0NTQwMzE5MywicGF0aCI6Ii8yOTI3NTAzMy80MzY0NzkxNjctMGZkZDU2MGUtZTA0Yi00MzdmLWE5NDgtMWM3NmE1OTUyNmU0LmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA0MjMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNDIzVDEwMTMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWQ2MjExZDRhNjA3OThjNzk0NGQwNzFmNjgwMzhmMmU5Yzg4ZmZmMmEwOTFjZmRmMTE0MjNlNmRjNTI4YzI4MWQmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.CbC1mxYpDOomLfvvv3S41bUZvfsjU1Kuz5jqOn67z0s) | ![Glitter GIF](https://private-user-images.githubusercontent.com/29275033/436480208-aaa30b5f-cab1-47ef-80f1-a45c265a6eff.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDU0MDM0OTMsIm5iZiI6MTc0NTQwMzE5MywicGF0aCI6Ii8yOTI3NTAzMy80MzY0ODAyMDgtYWFhMzBiNWYtY2FiMS00N2VmLTgwZjEtYTQ1YzI2NWE2ZWZmLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA0MjMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNDIzVDEwMTMxM1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWJkMTc2MzNhNTJiMjc1MWYwODg1YWRiOGFjNWVmOTMyODhmZmI5YzBhOTAwN2VkOTBkM2I4OTU3YTU4MzZlMGUmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.yJG1MKkRl53GDLvOJXs1O0Vn-ldkvcN23yAjmdivbks) |
(looks a bit laggy here but it's smooth on devices)

## 📦 Installation

Confetti3D is available via **Swift Package Manager (SPM)**. To install it, add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/maxime-day/Confetti3D.git", from: "1.0.0")
```

## Usage 

``` swift
struct Confetti3DTestView: View {
    
    private let confettiView = C3DView()

    var body: some View {
        ZStack {
            confettiView
        }
        .onAppear {
            confettiView.throwConfetti()
        }
    }
}
```

Two confetti types exist for now : `confetti` or `glitter` . `default` is confetti. 

You can customize the images for the confetti type : 

```swift
let customConfetti = [
        C3DConfetti(image: UIImage(named: "confetti_01")!,
                 color: .blue),
        C3DConfetti(image: UIImage(named: "confetti_02")!,
                 color: .green),
        C3DConfetti(image: UIImage(named: "confetti_03")!,
                 color: .yellow),
    ]
```

And also change some parameters (birth rate, emission duration, life span, and accelerometer) : 

```swift
confettiView.throwConfetti(type: .confetti(C3DConfettiOptions(confetti: customConfetti,
                                                              isAffectedByGravity: true,
                                                              birthRate: 20,
                                                              emissionDuration: 3,
                                                              lifeSpan: 15,
                                                              size: 1)))
``` 

The `glitter` type also has the same parameters for now. 