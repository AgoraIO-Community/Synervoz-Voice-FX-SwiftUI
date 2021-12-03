//
//  ContentView.swift
//  VoiceFX-SwiftUI
//
//  Created by Max Cobb on 29/11/2021.
//

import SwiftUI
import AgoraUIKit_iOS
import VoiceFiltersAgoraExtension

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

struct ContentView: View {
    @State var joinedChannel: Bool = false
    static var agview: AgoraViewer = {
        AgoraViewer(
            connectionData: AgoraConnectionData(
                appId: AppKeys.agoraAppId,
                rtcToken: AppKeys.agoraToken
            ),
            style: .floating
        )
    }()

    var body: some View {
        ZStack {
            VideoCallView(joinedChannel: $joinedChannel)
            if !joinedChannel {
                Button("Join Channel") {
                    self.joinChannel()
                }
            }
        }
    }

    func joinChannel() {
        self.joinedChannel = true
        ContentView.agview.viewer.enableExtension(
            withVendor: VoiceFiltersAgoraExtensionVendor,
            extension: VoiceFiltersAgoraExtensionName, enabled: true
        )
        ContentView.agview.join(
            channel: "test", with: AppKeys.agoraToken,
            as: .broadcaster
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
