//
//  VideoCallView.swift
//  VoiceFX-SwiftUI
//
//  Created by Max Cobb on 29/11/2021.
//

import SwiftUI
import AgoraUIKit_iOS
import VoiceFiltersAgoraExtension

struct VideoCallView: View {

    @State private var selection: String?

    static let voiceFilter: SynervozVoiceFilter = SynervozVoiceFilter()
    let names = [
        "echo",
        "reverb",
        "flanger",
        "pitch shift"
    ]

    @Binding var joinedChannel: Bool
    @State var voiceFxRegistered = false

    var body: some View {
        ZStack {
            ContentView.agview
            if joinedChannel {
                VStack {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(values: names) { name in
                                Button {
                                    selection = name
                                } label: {
                                    Text(name)
                                }
                            }
                            if selection != nil {
                                Button {
                                    selection = nil
                                } label: {
                                    Text("Clear")
                                    Spacer()
                                    Image(systemName: "clear")
                                }
                            }
                        } label: {
                            Image(systemName: "speaker.wave.3")
                            Text(selection ?? "Select a Voice")
                        }.padding(3).background(Color.black).cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                        .onChange(of: selection, perform: { value in
                            // update value for voice FX
                            self.setVoiceFxParam(to: selection ?? "null")
                        })
                        Spacer()

                        if selection != nil {
                            Button {
                                selection = nil
                            } label: {
                                Image(systemName: "xmark.circle")
                            }.padding(.trailing, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                    }
                    Spacer()
                }
            }
        }

    }

    enum VoiceEffect {
        case echo(EchoVoiceEffectConfiguration)
        case reverb(ReverbVoiceEffectConfiguration)
        case flanger(FlangerVoiceEffectConfiguration)
        case pitch(PitchShiftVoiceEffectConfiguration)
    }

    func getVoiceFilter(from name: String) -> VoiceEffect? {
        if name == "echo" {
            return .echo(EchoVoiceEffectConfiguration(mix: 1.0))
        } else if name == "reverb" {
            return .reverb(.init(
                dry: 0.9, wet: 0.3, mix: 0.6, width: 1.0,
                damp: 1.0, roomSize: 1.0, preDelay: 300.0, lowCut: 5.0
            ))
        } else if name == "flanger" {
            return .flanger(FlangerVoiceEffectConfiguration(
                wet: 1.0, depth: 1.0, lfoBeats: 30.0, bpm: 100.0, stereo: true
            ))
        } else if name == "pitch shift" {
            var pitch = PitchShiftVoiceEffectConfiguration()
            pitch.shift = 500
            return .pitch(pitch)
        }
        return nil
    }

    func registerVoiceFX() {

        // Set API Credentials
        ContentView.agview.viewer.setExtensionProperty(
            VoiceFiltersAgoraExtensionVendor, extension: VoiceFiltersAgoraExtensionName,
            key: VoiceFiltersAgoraExtensionApiKey, value: AppKeys.voiceFxApiKey
        )
        ContentView.agview.viewer.setExtensionProperty(
            VoiceFiltersAgoraExtensionVendor, extension: VoiceFiltersAgoraExtensionName,
            key: VoiceFiltersAgoraExtensionApiSecret, value: AppKeys.voiceFxApiSecret
        )
        print("set 1: \(set1)\nset 2: \(set2)")

        ContentView.agview.viewer.enableExtension(
            withVendor: VoiceFiltersAgoraExtensionVendor,
            extension: VoiceFiltersAgoraExtensionName, enabled: true
        )
        self.voiceFxRegistered = true

    }

    func setVoiceFxParam(to voiceName: String) {
        if !self.voiceFxRegistered {
            self.registerVoiceFX()
        }

        let newVoice = self.getVoiceFilter(from: voiceName)
        var enabledValues: [String: Bool] = [
            "echo": false,
            "reverb": false,
            "flanger": false,
            "pitchShift": false
        ]
        let agoraEngine = ContentView.agview.viewer.agkit
        VideoCallView.voiceFilter.enableEcho(true, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enableReverb(true, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enableFlanger(true, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enablePitchShift(true, inEngine: agoraEngine)
        switch newVoice {
        case .echo(let echoConfig):
            enabledValues["echo"] = true
            VideoCallView.voiceFilter.setEcho(echoConfig, inEngine: agoraEngine)
        case .reverb(let reverbConfig):
            enabledValues["reverb"] = true
            VideoCallView.voiceFilter.setReverbConfiguration(reverbConfig, inEngine: agoraEngine)
        case .flanger(let flangerConfig):
            enabledValues["flanger"] = true
            VideoCallView.voiceFilter.setFlangerConfiguration(flangerConfig, inEngine: agoraEngine)
        case .pitch(let pitchShiftConfig):
            enabledValues["pitchShift"] = true
            VideoCallView.voiceFilter.setPitchShiftConfiguration(pitchShiftConfig, inEngine: agoraEngine)
        case .none: break
        }
        VideoCallView.voiceFilter.enableEcho(enabledValues["echo"] ?? false, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enableReverb(enabledValues["reverb"] ?? false, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enableFlanger(enabledValues["flanger"] ?? false, inEngine: agoraEngine)
        VideoCallView.voiceFilter.enablePitchShift(enabledValues["pitchShift"] ?? false, inEngine: agoraEngine)

    }
}
