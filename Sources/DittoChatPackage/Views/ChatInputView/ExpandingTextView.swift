//
//  ExpandingTextView.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 7/19/22.
//  Copyright © 2022 DittoLive Incorporated. All rights reserved.
//

import SwiftUI

struct ExpandingTextView: View {
    /**
     * This is a UITextView Adapter to SwiftUI
     */
    struct WrappedTextView: UIViewRepresentable {
        typealias UIViewType = UITextView

        @Binding var text: String
        let textDidChange: (UITextView) -> Void

        func makeUIView(context: Context) -> UITextView {
            let view = UITextView()
            view.isEditable = true
            view.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
            view.backgroundColor = .clear
            view.delegate = context.coordinator
            return view
        }

        func updateUIView(_ uiView: UITextView, context _: Context) {
            uiView.text = text
            DispatchQueue.main.async {
                textDidChange(uiView)
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, textDidChange: textDidChange)
        }

        class Coordinator: NSObject, UITextViewDelegate {
            @Binding var text: String
            let textDidChange: (UITextView) -> Void

            init(text: Binding<String>, textDidChange: @escaping (UITextView) -> Void) {
                _text = text
                self.textDidChange = textDidChange
            }

            func textViewDidChange(_ textView: UITextView) {
                text = textView.text
                textDidChange(textView)
            }

            func textViewDidBeginEditing(_ textView: UITextView) {
                if textView.textColor == UIColor.lightGray {
                    textView.text = ""
                    textView.textColor = UIColor.black
                }
            }

            func textViewDidEndEditing(_ textView: UITextView) {
                if textView.text.isEmpty {
                    textView.text = messagesTitleKey
                    textView.textColor = UIColor.lightGray
                }
            }
        }
    }

    @Binding var text: String

    let minHeight: CGFloat = UIFont.systemFont(ofSize: UIFont.labelFontSize).lineHeight
    @State private var height: CGFloat?

    var body: some View {
        WrappedTextView(text: $text, textDidChange: textDidChange)
            .frame(height: height ?? minHeight)
    }

    @MainActor
    private func textDidChange(_ textView: UITextView) {
        guard let lineHeight = textView.font?.lineHeight else { return }
        height = max(textView.contentSize.height, lineHeight)
    }
}

#if DEBUG
struct ExpandingTextView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandingTextView(text: .constant("foo"))
    }
}
#endif
