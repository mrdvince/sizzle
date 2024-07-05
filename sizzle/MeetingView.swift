//
//  ContentView.swift
//  sizzle
//
//  Created by vince on 05/07/2024.
//

import SwiftUI

struct MeetingView: View {
  var body: some View {
    VStack {
      ProgressView(value: 10, total: 20)
      HStack {
        VStack(alignment: .leading) {
          Text("Seconds Elapsed").font(.caption)
          Label("300", systemImage: "hourglass.tophalf.fill")
        }
        Spacer()
        VStack(alignment: .trailing) {
          Text("Seconds Remaining").font(.caption)
          Label("600", systemImage: "hourglass.bottomhalf.fill")
        }
      }
      Circle().strokeBorder(lineWidth: 24, antialiased: true)
    }

  }
}

#Preview {
  MeetingView()
}
