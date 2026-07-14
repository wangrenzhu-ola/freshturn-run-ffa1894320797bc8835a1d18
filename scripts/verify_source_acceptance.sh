#!/bin/zsh
set -euo pipefail

repo_root="${0:A:h:h}"
cd "$repo_root"

plutil -lint FreshTurnApp/Resources/Info.plist FreshTurnApp/Resources/PrivacyInfo.xcprivacy

rg -q 'SWIFT_VERSION = 5.0;' FreshTurn.xcodeproj/project.pbxproj
rg -q 'IPHONEOS_DEPLOYMENT_TARGET = 14.0;' FreshTurn.xcodeproj/project.pbxproj
rg -q 'NSCameraUsageDescription' FreshTurnApp/Resources/Info.plist
rg -q 'NSPhotoLibraryUsageDescription' FreshTurnApp/Resources/Info.plist
rg -q 'VNRecognizeTextRequest' FreshTurnApp/Services/ReceiptOCRService.swift
rg -q 'receiptText: String' FreshTurnApp/Services/KimiReceiptParser.swift
rg -q 'cloudConsent' FreshTurnApp/Features/NewRescueView.swift
rg -q 'Retry Parsing' FreshTurnApp/Features/ReceiptCaptureComponents.swift
rg -q 'Continue Manually' FreshTurnApp/Features/ReceiptCaptureComponents.swift
rg -q 'Cancel Without Saving' FreshTurnApp/Features/ReceiptCaptureComponents.swift
rg -q 'Save Rescue' FreshTurnApp/Features/CandidateReview.swift
rg -q 'not food-safety or edibility advice' FreshTurnApp/Features/CandidateReview.swift
rg -q 'prefix\(max\(0, limit\)\)' Sources/FreshTurnCore/RescueLogic.swift
rg -q 'Data\(contentsOf: fileURL\)' Sources/FreshTurnCore/RescueRepository.swift
rg -q 'No account · No tracking · No receipt image upload' FreshTurnApp/Features/PrivacySettingsView.swift

if rg -n 'sk-kimi-[A-Za-z0-9]|(apiKey|api_key)[[:space:]]*=' FreshTurnApp Sources Tests; then
  print -u2 'embedded_secret_pattern_detected'
  exit 1
fi

if rg -n 'simctl|generic/platform=iOS Simulator|iPhoneSimulator' README.md project.yml FreshTurnApp Sources Tests; then
  print -u2 'simulator_runtime_claim_or_command_detected'
  exit 1
fi

swift package dump-package >/dev/null
print 'SOURCE_ACCEPTANCE_AUDIT_PASS'
