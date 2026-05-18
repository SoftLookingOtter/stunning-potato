//
//  RecordView.swift
//  Echoes
//
//  Created by Sara Lindén on 2026-05-17.
//  Updated by Mikael Engvall on 2026-05-18

import SwiftUI

struct RecordView: View {
    
    @State private var viewModel = RecordViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(viewModel.isRecording ? "Recording..." : "Ready to Record")
            
            Button {
                viewmodel.toggleRecording()
            } label: {
                Text(viewModel.isRecording ?  "Stop Recording" : "Start Recording")
            }
        }
    }
}

#Preview {
    RecordView()
}

