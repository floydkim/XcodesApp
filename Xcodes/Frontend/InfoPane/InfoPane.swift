import AppKit
import Path
import SwiftUI
import Version
import struct XCModel.Compilers
import struct XCModel.SDKs

struct InfoPane: View {
    @EnvironmentObject var appState: AppState
    let selectedXcodeID: Xcode.ID?

    var body: some View {
        if let xcode = appState.allXcodes.first(where: { $0.id == selectedXcodeID }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    IconView(installState: xcode.installState)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(verbatim: "Xcode \(xcode.description) \(xcode.version.buildMetadataIdentifiersDisplay)")
                        .font(.title)

                    switch xcode.installState {
                    case .notInstalled:
                        NotInstalledStateButtons(
                            downloadFileSizeString: xcode.downloadFileSizeString,
                            id: xcode.id
                        )
                    case let .installing(installationStep):
                        InstallationStepDetailView(installationStep: installationStep)
                        CancelInstallButton(xcode: xcode)
                    case .installed:
                        InstalledStateButtons(xcode: xcode)
                    }

                    Divider()

                    Group {
                        ReleaseNotesView(url: xcode.releaseNotesURL)
                        ReleaseDateView(date: xcode.releaseDate)
                        IdenticalBuildsView(builds: xcode.identicalBuilds)
                        CompatibilityView(requiredMacOSVersion: xcode.requiredMacOSVersion)
                        SDKsView(sdks: xcode.sdks)
                        CompilersView(compilers: xcode.compilers)
                    }

                    Spacer()
                }
                .padding()
            }
            .frame(minWidth: 200, maxWidth: .infinity)
        } else {
            UnselectedView()
        }
    }
}

struct InfoPane_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InfoPane(selectedXcodeID: Version(major: 12, minor: 3, patch: 0))
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                        .init(
                            version: Version(major: 12, minor: 3, patch: 0),
                            installState: .installed(Path("/Applications/Xcode-12.3.0.app")!),
                            selected: true,
                            icon: NSWorkspace.shared.icon(forFile: "/Applications/Xcode-12.3.0.app"),
                            requiredMacOSVersion: "10.15.4",
                            releaseNotesURL: URL(string: "https://developer.apple.com/documentation/xcode-release-notes/xcode-12_3-release-notes/")!,
                            releaseDate: Date(),
                            sdks: SDKs(
                                macOS: .init(number: "11.1"),
                                iOS: .init(number: "14.3"),
                                watchOS: .init(number: "7.3"),
                                tvOS: .init(number: "14.3")
                            ),
                            compilers: Compilers(
                                gcc: .init(number: "4"),
                                llvm_gcc: .init(number: "213"),
                                llvm: .init(number: "2.3"),
                                clang: .init(number: "7.3"),
                                swift: .init(number: "5.3.2")
                            ),
                            downloadFileSize: 242_342_424
                        ),
                    ]
                })
                .previewDisplayName("Populated, Installed, Selected")

            InfoPane(selectedXcodeID: Version(major: 12, minor: 3, patch: 0))
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                        .init(
                            version: Version(major: 12, minor: 3, patch: 0),
                            installState: .installed(Path("/Applications/Xcode-12.3.0.app")!),
                            selected: false,
                            icon: NSWorkspace.shared.icon(forFile: "/Applications/Xcode-12.3.0.app"),
                            sdks: SDKs(
                                macOS: .init(number: "11.1"),
                                iOS: .init(number: "14.3"),
                                watchOS: .init(number: "7.3"),
                                tvOS: .init(number: "14.3")
                            ),
                            compilers: Compilers(
                                gcc: .init(number: "4"),
                                llvm_gcc: .init(number: "213"),
                                llvm: .init(number: "2.3"),
                                clang: .init(number: "7.3"),
                                swift: .init(number: "5.3.2")
                            ),
                            downloadFileSize: 242_342_424
                        ),
                    ]
                })
                .previewDisplayName("Populated, Installed, Unselected")

            InfoPane(selectedXcodeID: Version(major: 12, minor: 3, patch: 0))
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                        .init(
                            version: Version(major: 12, minor: 3, patch: 0),
                            installState: .notInstalled,
                            selected: false,
                            icon: nil,
                            sdks: SDKs(
                                macOS: .init(number: "11.1"),
                                iOS: .init(number: "14.3"),
                                watchOS: .init(number: "7.3"),
                                tvOS: .init(number: "14.3")
                            ),
                            compilers: Compilers(
                                gcc: .init(number: "4"),
                                llvm_gcc: .init(number: "213"),
                                llvm: .init(number: "2.3"),
                                clang: .init(number: "7.3"),
                                swift: .init(number: "5.3.2")
                            ),
                            downloadFileSize: 242_342_424
                        ),
                    ]
                })
                .previewDisplayName("Populated, Uninstalled")

            InfoPane(selectedXcodeID: Version(major: 12, minor: 3, patch: 1, buildMetadataIdentifiers: ["1234A"]))
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                        .init(
                            version: Version(major: 12, minor: 3, patch: 1, buildMetadataIdentifiers: ["1234A"]),
                            installState: .installed(Path("/Applications/Xcode-12.3.0.app")!),
                            selected: false,
                            icon: nil,
                            sdks: nil,
                            compilers: nil
                        ),
                    ]
                })
                .previewDisplayName("Basic, installed")

            InfoPane(selectedXcodeID: Version(major: 12, minor: 3, patch: 1, buildMetadataIdentifiers: ["1234A"]))
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                        .init(
                            version: Version(major: 12, minor: 3, patch: 1, buildMetadataIdentifiers: ["1234A"]),
                            installState: .installing(.downloading(progress: configure(Progress(totalUnitCount: 100)) { $0.completedUnitCount = 40; $0.throughput = 232_323_232; $0.fileCompletedCount = 2_323_004; $0.fileTotalCount = 1_193_939_393 })),
                            selected: false,
                            icon: nil,
                            sdks: nil,
                            compilers: nil
                        ),
                    ]
                })
                .previewDisplayName("Basic, installing")

            InfoPane(selectedXcodeID: nil)
                .environmentObject(configure(AppState()) {
                    $0.allXcodes = [
                    ]
                })
                .previewDisplayName("Empty")
        }
        .frame(maxWidth: 300)
    }
}
