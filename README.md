# 🎉 ConfettiKit

**ConfettiKit** is a lightweight and customizable Swift package that allows you to easily add confetti effects to your iOS applications using **SwiftUI** or **UIKit**. Under the hood, it leverages **SceneKit** to provide smooth and efficient 3D confetti animations.

## ✨ Features

- 🎨 Fully customizable confetti shapes, colors, and behaviors  
- 🏎️ Optimized for performance using SceneKit  
- 📱 Works seamlessly with both SwiftUI and UIKit  
- 🛠️ Simple and easy-to-use API  

![Confetti GIF](confetti.gif)
![Glitter GIF](glitter.gif)

## 📦 Installation

ConfettiKit is available via **Swift Package Manager (SPM)**. To install it, add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/maxime-day/Confetti3D.git", from: "1.0.0")
```

## Usage 

``` swift
struct Confetti3DTestView: View {
    
    private let confettiView = C3DView()

    var body: some View {
        ZStack {
            Text("🎉 Confetti time! 🎉")
                .foregroundColor(.white)
            confettiView
        }
        .background(.black)
        .onTapGesture {
            confettiView.throwConfetti()
        }
    }
}

#Preview {
    Confetti3DTestView()
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
        C3DConfetti(image: UIImage(named: "confetti_04")!,
                 color: .purple),
        C3DConfetti(image: UIImage(named: "confetti_05")!,
                 color: .red),
        C3DConfetti(image: UIImage(named: "confetti_06")!,
                 color: .cyan),
        C3DConfetti(image: UIImage(named: "confetti_07")!,
                 color: UIColor(red: 1, green: 0.1, blue: 0, alpha: 1)), // Orange
        C3DConfetti(image: UIImage(named: "confetti_08")!,
                 color: UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)), // Gold
    ]
```

And also change some parameters (birth rate, emission duration, life span, and accelerometer) : 

```swift
confettiView.throwConfetti(type: .confetti(C3DConfettiOptions(confetti: customConfetti,
                                                              isAffectedByGravity: true,
                                                              birthRate: 20,
                                                              emissionDuration: 3,
                                                              lifeSpan: 15)))
``` 

The `glitter` type also has parameters: 

```swift
confettiView.throwConfetti(type: .glitter(C3DConfettiOptions(isAffectedByGravity: true,
                                                             birthRate: 20,
                                                             emissionDuration: 3,
                                                             lifeSpan: 15)))
```
