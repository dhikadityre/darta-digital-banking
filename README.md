# Darta iOS Application (SwiftUI)

**DARTA Digital Banking**

DARTA is a sample digital banking application built with Swift and SwiftUI, featuring QR-based payments and essential banking functionalities.

### About the Name

DARTA is derived from two elements:

*   **D** — inspired by Dhika, the developer behind this project.
*   **Arta** — an Indonesian word associated with wealth, assets, and financial value.

Together, DARTA represents a personal take on a modern Indonesian digital banking brand, combining a personal identity with a financial concept.

---

Native iOS Client for the **Darta** application. This app integrates user authentication, simulated balances & withdrawal limits, server-signed QR withdrawal ticket creation, and Cashier mode to scan and redeem QR codes in real-time.

---

## 📱 Key Features

*   **Customer Mode**:
    *   Simulated balance & daily/per-transaction withdrawal limits via the `/api/accounts/{email}/limits` endpoint.
    *   Active countdown & automatic refresh of the QR code before expiration.
*   **Cashier Mode**:
    *   QR code scanning using the physical camera (`AVCaptureMetadataOutput`) for instant cash redemption via `/api/withdrawals/dispense`.
    *   Contextual handling of camera permissions with a fallback navigation to Settings.
*   **In-App Debugger**:
    *   Integrated with `DebugSwift` to monitor performance, network logs, and environment configurations directly inside the app.

---

## 🛠️ System Requirements

| Requirement | Minimum Version | Description |
| :--- | :--- | :--- |
| **Operating System** | macOS Sequoia (or compatible) | Required to run the latest version of Xcode |
| **Xcode Version** | `16.2+` | Required for Swift 6.2 compiler support |
| **Swift Version** | `6.2` | Enables strict concurrency checks |
| **iOS Deployment Target** | `iOS 16.0+` | Uses modern SwiftUI & NavigationStack features |
| **Physical Device** | Required for Cashier Mode | Xcode Simulator does not support a physical camera |

---

## 📐 Architecture Overview

This project implements **Clean Architecture & SOLID** principles with strict decoupling using a **Modular Local Swift Package Manager (SPM)** structure:

```
ios/
├── Darta/                         # Main Target (Presentation & UI Layer)
│   ├── App/                         # DartaApp entry point & Lifecycle Coordinator
│   ├── Presentation/                # SwiftUI Views, ViewModels, & Router Coordinator
│   ├── Utilities/                   # Helpers & Extensions
│   └── XCConfig/                    # [NEW/LOCAL] Build configuration target files (.xcconfig)
│
├── CoreDomain/                      # Local SPM Package (Domain Layer)
│   ├── Sources/CoreDomain/          # Core Business Logic: Entities, Use Cases, & Repository Contracts
│   └── Tests/CoreDomainTests/       # pure Business Logic Unit Tests (Fast, No Simulator)
│
└── PackageData/                     # Local SPM Package (Data Layer)
    ├── Sources/PackageData/         # Infrastructure: API Client, DTOs, Mappers, & Concrete Repositories
    └── Tests/PackageDataTests/      # Data integration & parsing Unit Tests (Fast, No Simulator)
```

---

## 📦 Dependencies & Libraries

Dependencies are categorized into two main areas:

1.  **Modular Local Package (Swift Package Manager)**:
    *   [CoreDomain](file:///Users/dhikadityre/Documents/Project/dhikadityre/ios/CoreDomain) - Contains Entities, Use Cases, and abstract Repository protocols.
    *   [PackageData](file:///Users/dhikadityre/Documents/Project/dhikadityre/ios/PackageData) - Contains concrete repository implementations, REST API client, DTOs, and data mapping.
2.  **Third-Party Package (Remote SPM)**:
    *   [DebugSwift](https://github.com/DebugSwift/DebugSwift) (`1.18.0`) - In-app debugging toolkit for HTTP request inspection, UI performance, and CoreData/File logs.

---

## ⚙️ Configuration Setup Guide (`XCConfig`)

For security reasons regarding sensitive data and API credentials, all build configuration `.xcconfig` files are added to `.gitignore` and are **NOT** stored in the Git repository.

### Setup Steps:

1.  **Obtain the Credentials File**:
    *   Ensure you have the `XCConfig.zip` file (if you do not have it, contact the **Lead Developer**).
2.  **File Placement**:
    *   Copy and place the `XCConfig.zip` file inside the `Darta/` directory (parallel to the `Darta.xcodeproj` file).
    *   *Target location*: `ios/Darta/XCConfig.zip`
3.  **Run the Installation Script**:
    *   Open Terminal in the project's root directory, then run the setup script:
        ```bash
        chmod +x Darta/script/setup_xcconfig.sh
        ./Darta/script/setup_xcconfig.sh
        ```
    *   *What does this script do?*
        *   Extracts the `XCConfig.zip` file into the target directory `Darta/XCConfig/`.
        *   Creates a backup if the target directory already exists.
        *   Clears local Xcode build cache & Derived Data.
        *   Synchronizes and resolves project Package Dependencies.
4.  **Verify File Placement**:
    Once the script runs successfully, ensure the `Darta/XCConfig/` directory contains the following configuration files:
    *   `Base.xcconfig` - Base project configurations.
    *   `Development.xcconfig` - Credentials & dev API URL.
    *   `Staging.xcconfig` - Staging server configuration.
    *   `UAT.xcconfig` - UAT testing server configuration.
    *   `Production.xcconfig` - Production server configuration.

---

## 🚀 Build Schemes & Environments

The project has several target schemes tailored to release cycles and testing requirements:

*   **`Darta-Development`**: Connects the app to the dev server.
*   **`Darta-Staging`**: Used for internal integration testing in the staging environment.
*   **`Darta-UAT`**: Used for User Acceptance Testing (UAT) with data mirroring production.
*   **`Darta-Production`**: Final configuration for App Store distribution with maximum security protection.
*   **`DartaPresentationTest`**: A dedicated scheme for running UI & Presentation Layer tests in the simulator.

> [!TIP]
> When switching schemes in Xcode, ensure the selected scheme matches the intended target API server to ensure smooth testing.

---

## 🧪 Running Unit Tests

To speed up the development process and integration with CI/CD (Jenkins), unit tests are designed to run efficiently:

### 1. Standalone Unit Tests in macOS Environment (Ultra Fast ⚡)

Unit tests for the CoreDomain and PackageData modules do not require an iOS simulator. They can be executed natively using the Swift compiler on your Mac, saving significant simulator startup time.

You can run these tests in two ways:

#### A. Using Xcode Scheme

Open the project in Xcode, then choose and run one of the following target schemes:

*   **`CoreDomain`**: Scheme for running pure Business Logic unit tests in the CoreDomain module.
*   **`PackageData`**: Scheme for running data integration unit tests in the PackageData module.

*(Select the scheme and press `Cmd + U` to execute).*

#### B. Using Swift CLI (Terminal / Jenkins)

Execute tests directly using the command line inside the respective module directories:

*   **CoreDomain**:
    ```bash
    cd CoreDomain && swift test
    ```
    *(Or run using the `CoreDomain` scheme in Xcode)*
*   **PackageData**:
    ```bash
    cd PackageData && swift test
    ```
    *(Or run using the `PackageData` scheme in Xcode)*

### 2. Presentation & UI Unit Tests (Using iOS Simulator)

To test UI components and presentation flow, use the `DartaPresentationTest` scheme on the iOS Simulator.

*   **Via Xcode**: Select the `DartaPresentationTest` scheme -> press `Cmd + U`.
*   **Via Terminal / Jenkins**: Run the integrated test runner script:
    ```bash
    ./Darta/script/run_tests.sh
    ```
    *(This script automatically detects a compatible iPhone simulator and executes the test target).*

---

## 🔑 Demo Credentials

To log into the app in the testing environment, use the following credentials:

*   **Username**: `alex@darta.demo`
*   **Password**: `cash1234`

*Note: All balance, transaction history, and withdrawal data shown are purely simulated.*
