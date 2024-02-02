//
//  PreviewView.swift
//  DittoChat
//
//  Created by Eric Turner on 1/29/23.
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.
//
//  Credit to Natalia Panferova
//  https://nilcoalescing.com/blog/PreviewFilesWithQuickLookInSwiftUI/
//

#if canImport(QuickLook)
import QuickLook
#endif
import SwiftUI

#if !os(tvOS)
struct PreviewView: View {
    let fileURL: URL

    var body: some View {
        PreviewViewController(url: fileURL)
    }
}

struct PreviewViewController: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_: QLPreviewController, context _: Context) { /*protocol conformance*/ }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: QLPreviewControllerDataSource {
        let parent: PreviewViewController

        init(parent: PreviewViewController) {
            self.parent = parent
        }

        func numberOfPreviewItems(in _: QLPreviewController) -> Int {
            1
        }

        func previewController(
            _: QLPreviewController,
            previewItemAt _: Int
        ) -> QLPreviewItem {
            parent.url as NSURL
        }
    }
}
#endif
