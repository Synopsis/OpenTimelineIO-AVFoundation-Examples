//
//  AppDelegate.swift
//  OpenTimelineIO-AVFoundation-Examples
//
//  Created by Anton Marini on 2/10/24.
//

import Cocoa
import AVKit
import AVFoundation
import CoreMedia
import OpenTimelineIO_AVFoundation
import OpenTimelineIO
import MediaToolbox
import VideoToolbox

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @MainActor @IBOutlet var window: NSWindow!

    @MainActor @IBOutlet weak var playerView: AVPlayerView!
    
    @MainActor let player = AVPlayer()
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
        MTRegisterProfessionalVideoWorkflowFormatReaders()
        VTRegisterProfessionalVideoWorkflowVideoDecoders()
        VTRegisterProfessionalVideoWorkflowVideoEncoders()
        VTRegisterSupplementalVideoDecoderIfAvailable(kCMVideoCodecType_AV1)
        VTRegisterSupplementalVideoDecoderIfAvailable(kCMVideoCodecType_VP9)

        self.playerView.player = self.player
        self.playerView.allowsVideoFrameAnalysis = false
        self.playerView.showsFrameSteppingButtons = true
        self.playerView.showsTimecodes = true
        self.playerView.showsFullScreenToggleButton = true
        self.playerView.showsSharingServiceButton = true
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        return false
    }

    @IBAction func open(_ sender: Any) 
    {
        let open = NSOpenPanel()
        
        open.allowedContentTypes = [ UTType(filenameExtension: "otio")! ]
        
        let response = open.runModal()
            
        if response == .OK
        {
            self.loadOTIOFileFrom(url: open.url!)
        }
    }
    
    @IBAction func export(sender:Any)
    {
        let save = NSSavePanel()
        
        save.allowedContentTypes = [ .mpeg4Movie ]
        
        let response = save.runModal()
            
        if response == .OK
        {
            self.exportToURL(url: save.url!)
        }
    }
    
    private func loadOTIOFileFrom(url:URL)
    {
        Task
        {
            do {
                if
                    let timeline = try Timeline.fromJSON(url: url) as? Timeline,
                    let (composition, videoComposition, audioMix) = try await timeline.toAVCompositionRenderables(baseURL: url.deletingLastPathComponent() , useAssetTimecode: false)
                {
                    let playerItem = AVPlayerItem(asset: composition)
                    playerItem.videoComposition = videoComposition
                    playerItem.audioMix = audioMix
                    
                    await MainActor.run {
                        self.player.replaceCurrentItem(with: playerItem)
                    }
                }
            }
            catch
            {
                print(error)
            }
        }
    }
    
    private func exportToURL(url:URL)
    {
        if
            let currentItem = self.player.currentItem,
            let videoComposition = currentItem.videoComposition,
            let audioMix = currentItem.audioMix
        {
            let composition = currentItem.asset

            let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.videoComposition = videoComposition
            exportSession?.audioMix = audioMix
            exportSession?.outputURL = url
            exportSession?.outputFileType = .mp4

            exportSession?.exportAsynchronously(completionHandler: {
                NSWorkspace.shared.open(url)
            })
        }
        
    }
    
    
}

