# ARViewUIKit

A sophisticated iOS Augmented Reality application that provides an immersive experience for viewing, manipulating, and documenting industrial equipment models. The app combines AR visualization with machine scanning capabilities and cloud integration, allowing users to load USDZ models, interact with them in 3D space, and place them in real-world environments.

## 🚀 Features

### Core Functionality
- **USDZ Model Loading & Visualization**
  - Load and display USDZ 3D models
  - View comprehensive model information:
    - Individual parts listing
    - Rotation parameters
    - Geometry specifications
    - Material properties
- **Interactive Part Selection**
  - Select and highlight individual model parts
  - Dynamic color change on part selection
  - Bouncing arrow indicators for selected parts
  - Visual feedback for part identification
- **3D Model Interaction**
  - Pinch-to-zoom functionality
  - 360-degree rotation support
  - Multi-touch gesture recognition
  - Smooth model manipulation
- **AR Room Scanning & Placement**
  - Real-time room scanning capabilities
  - Accurate model placement in physical space
  - Surface detection and tracking
  - Scale adjustment for realistic visualization

### Documentation & Media
- **Photo Capture**
  - Take high-quality screenshots of AR models
  - Save images with model context
  - Export for documentation purposes
- **Video Recording**
  - Record AR model interactions
  - Capture model placement process
  - Create training or demonstration videos

### PDF Management
- **Local PDF Access**
  - Retrieve all PDF files from device
  - Display technical documentation
  - Machine manuals integration
- **PDF Sharing**
  - Share documentation with team members
  - Export PDFs via native sharing options
  - Support for multiple file formats

### Multi-Model Support
- **Load Multiple Models**
  - Display several models simultaneously
  - Compare different equipment versions
  - Visualize model relationships
- **Arrow Indicators**
  - Show directional guidance
  - Highlight model connections
  - Provide visual navigation aids

### AR Experience Enhancements
- **Coaching Overlay**
  - Interactive AR setup guidance
  - User-friendly onboarding process
  - Real-time tracking feedback

### Communication Features
- **Contact Integration**
  - Initiate AR video calls
  - Standard voice calling
  - Integrated contact management

### Planned Features
- **LiDAR Scanner Integration**
  - Machine scanning capabilities
  - USDZ file export functionality
  - High-precision 3D model generation
  - Point cloud generation

- **Cloud Integration**
  - AWS S3 bucket integration for machine data storage
  - Machine data retrieval and synchronization
  - Real-time data updates

- **Local Data Management**
  - SwiftData integration for local storage
  - Offline data access
  - Data synchronization with cloud

## 🛠 Technical Stack

### Frameworks & Technologies
- **Swift** - Primary programming language
- **SwiftUI** - Modern declarative UI
- **UIKit** - Traditional UI components
- **ARKit** - Augmented reality foundation
- **RealityKit** - High-performance 3D rendering
- **SceneKit** - 3D graphics and animation
- **Combine** - Reactive programming
- **SwiftData** - Local data persistence
- **AWS SDK for iOS** - Cloud integration

### Architecture
The application follows Clean Architecture principles:
- **Domain Layer** - Business logic and entities
- **Data Layer** - Repository implementations and data sources
- **Presentation Layer** - ViewModels and Views
- **Use Cases** - Application-specific business rules

### Key Design Patterns
- **MVVM** - Model-View-ViewModel for UI management
- **Repository Pattern** - Abstraction for data access
- **Coordinator Pattern** - Navigation flow management
- **Dependency Injection** - Loose coupling between components

## 📱 Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- iPhone or iPad with A12 Bionic chip or later
- Device with LiDAR scanner (for scanning features)
- ARKit compatible device

## 🔧 Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/ARViewUIKit.git
```

2. Open `ARViewUIKit.xcodeproj` in Xcode

3. Add dependencies using Swift Package Manager (SPM):
   - In Xcode, go to File > Add Packages
   - Add required packages:
     - AWS SDK for iOS
     - Any other required dependencies

4. Configure AWS credentials
   - Add your AWS configuration file
   - Set up necessary environment variables

5. Configure signing and capabilities in Xcode

6. Build and run on a physical device (AR features require actual hardware)

## 📝 Usage

### AR Visualization
1. Launch the app
2. Tap the "ARView" button
3. Allow camera access
4. Use the focus square to place 3D objects
5. Interact with placed objects using gestures

### Model Interaction
1. Load USDZ models from local storage or remote source
2. Use multi-touch gestures to manipulate models
3. Place models in real-world space
4. Capture photos or record videos of the AR experience

### Documentation
1. Access PDF files from device storage
2. View technical documentation
3. Share documentation with team members

### Machine Scanning (Coming Soon)
1. Access the scanning interface
2. Use LiDAR scanner to capture machine data
3. Export to USDZ format
4. Upload to AWS S3 bucket

### Data Management (Coming Soon)
1. View machine data from cloud
2. Access local cached data
3. Sync data between local and cloud storage

## 🔐 Permissions

The app requires the following permissions:
- Camera - For AR functionality and photo/video capture
- Photo Library - To save captured media
- Files - To access PDF documents
- Microphone - For video recording with audio

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 👤 Author

Adnann Muratovic

## 🙏 Acknowledgments

- ARKit documentation
- RealityKit documentation
- AWS SDK for iOS
- Apple's LiDAR Scanner documentation
- SceneKit documentation
- Combine framework documentation

