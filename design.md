# unsent - design document

## 📱 features

### core features
- [ ] write and save unsent messages privately
- [ ] categorize messages (apology, confession, love letter, etc.)
- [ ] search and filter messages
- [ ] dark/light mode support
- [ ] local data persistence
- [ ] public community feed to view shared messages
- [ ] anonymous sharing to public feed
- [ ] privacy controls (private vs public messages)

### nice-to-have features
- [ ] export messages to share to social media
- [ ] password protection for private messages (authentication)
- [ ] cloud sync (iCloud) for private messages
- [ ] widgets for quick access
- [ ] like/react to public messages
- [ ] follow other users (optional)
- [ ] message themes and backgrounds

## 🛠 development roadmap

### phase 1: project setup & basics 
1. **set up Xcode project**
   - create new ios app with swiftui
   - configure app icons and launch screen
   - set up basic project structure

2. **learn SwiftUI fundamentals**
   - views, modifiers, and state management
   - navigation and tab views
   - basic data models

3. **create basic UI structure**
   - main tab view (Messages, Community, Settings)
   - message list view
   - basic message detail view

### phase 2: core functionality 
1. **implement data models**
   - message model with core data
   - category model
   - user preferences

2. **build message management**
   - create new message functionality
   - edit existing messages
   - delete messages
   - message list with search

3. **add privacy controls**
   - private vs public message toggle
   - anonymous sharing functionality
   - privacy settings

### phase 3: community features 
1. **build community feed**
   - public message display
   - anonymous posting
   - like/react functionality
   - community guidelines

2. **enhance UI/UX**
   - custom animations
   - better typography
   - improved layouts
   - accessibility features

3. **testing and refinement**
   - bug fixes
   - performance optimization
   - user testing

### phase 4: deployment 
1. **app store preparation**
   - app icon and screenshots
   - app description and metadata
   - privacy policy
   - app store connect setup

2. **final testing**
   - device testing
   - beta testing
   - performance monitoring

## 🎨 design principles

- **minimalist design**: clean, distraction-free writing experience
- **emotional safety**: private, secure space for personal thoughts with option for public sharing
- **community connection**: anonymous sharing to connect with others through shared experiences
- **privacy first**: clear distinction between private and public content
- **accessibility**: inclusive design for all users
- **performance**: fast, responsive app experience

## 🛠 technical stack

- **language**: Swift 5.9+
- **framework**: SwiftUI
- **data persistence**: Core Data (private) + backend API (public)
- **target**: iOS 17.0+
- **development**: Xcode 15+

## 📁 project structure (planned)

```
Unsent/
├── Unsent/
│   ├── App/
│   │   └── UnsentApp.swift
│   ├── Models/
│   │   ├── Message.swift
│   │   ├── Category.swift
│   │   └── User.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── MessageListView.swift
│   │   ├── MessageDetailView.swift
│   │   ├── MessageEditorView.swift
│   │   ├── CommunityFeedView.swift
│   │   └── SettingsView.swift
│   ├── ViewModels/
│   │   ├── MessageViewModel.swift
│   │   └── CommunityViewModel.swift
│   ├── Services/
│   │   ├── CoreDataManager.swift
│   │   └── APIService.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
├── UnsentTests/
└── README.md
```

## 📚 my learning resources

### SwiftUI & iOS Development
- [Apple's SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com)
- [SwiftUI by Example](https://www.hackingwithswift.com/quick-start/swiftui)

### Design & UX
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [iOS Design Patterns](https://developer.apple.com/design/human-interface-guidelines/ios/overview/themes/)

### Core Data
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html)

## 🚀 getting started

1. **prerequisites**
   - macOS with Xcode 15+
   - iOS 17.0+ device or simulator
   - Apple Developer account (for App Store deployment)

2. **setup instructions**
   ```bash
   # Clone the repository
   git clone [your-repo-url]
   cd unsent
   
   # Open in Xcode
   open Unsent.xcodeproj
   ```

3. **build and run**
   - select your target device/simulator
   - press Cmd+R to build and run
   - the app should launch on your device/simulator

## 🎯 next steps

1. **start with Phase 1** - setting up your Xcode project
2. **follow the learning resources** - building my swiftui foundation
3. **implement features incrementally** - not trying to build everything at once
4. **test frequently** - use the iOS Simulator and real devices
5. **document your learning** - keeping notes of what I learn