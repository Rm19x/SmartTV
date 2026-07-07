--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

{-# LANGUAGE OverloadedStrings #-}

module Drivers.WebOS
  ( sendWebOSCommand
  ) where

import Types
import Network.WebSockets
import Data.Aeson
import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as BL


sendWebOSCommand :: String -> TVCommand -> Maybe String -> IO ()
sendWebOSCommand ip cmd maybeToken = do
  let port = 3000
  putStrLn $ "[*] Menghubungkan ke saluran WebSocket LG WebOS (" ++ ip ++ ")..."
  
  runClient ip port "/" $ \conn -> do

    let clientKey = maybe "" T.pack maybeToken
        regPacket = object
          [ "type" .= ("register" :: T.Text)
          , "id"   .= ("register_01" :: T.Text)
          , "payload" .= object [ "client-key" .= clientKey ]
          ]
    sendTextData conn (encode regPacket)
    

    _ <- receiveData conn :: IO BL.ByteString
    

    case cmd of
      ShowToast msg -> do

        let toastPacket = object
              [ "type" .= ("request" :: T.Text)
              , "id"   .= ("toast_01" :: T.Text)
              , "uri"  .= ("ssap://system.notifications/createToast" :: T.Text)
              , "payload" .= object [ "message" .= T.pack msg ]
              ]
        sendTextData conn (encode toastPacket)
        putStrLn "[+] [WebOS] Notifikasi berhasil ditampilkan di layar TV!"
        
      LaunchApp app -> do

        let appId = convertAppToWebOS app
            appPacket = object
              [ "type" .= ("request" :: T.Text)
              , "id"   .= ("launch_01" :: T.Text)
              , "uri"  .= ("ssap://system.launcher/launch" :: T.Text)
              , "payload" .= object [ "id" .= appId ]
              ]
        sendTextData conn (encode appPacket)
        putStrLn $ "[+] [WebOS] Aplikasi " ++ show app ++ " berhasil diluncurkan."
        
      _ -> do

        let (uri, payloadKey, payloadVal) = convertCmdToWebOS cmd
        when (uri /= "") $ do
          let genericPacket = object
                [ "type" .= ("request" :: T.Text)
                , "id"   .= ("cmd_01" :: T.Text)
                , "uri"  .= uri
                , "payload" .= object [ payloadKey .= payloadVal ]
                ]
          sendTextData conn (encode genericPacket)
          putStrLn $ "[+] [WebOS] Perintah eksekusi makro sukses dikirim."


convertAppToWebOS :: AppID -> T.Text
convertAppToWebOS YouTube    = "youtube.leanback.v4"
convertAppToWebOS Netflix    = "netflix"
convertAppToWebOS Spotify    = "spotify-tv"
convertAppToWebOS PrimeVideo = "amazon"


convertCmdToWebOS :: TVCommand -> (T.Text, T.Text, T.Text)
convertCmdToWebOS VolumeUp   = ("ssap://audio/volumeUp", "", "")
convertCmdToWebOS VolumeDown = ("ssap://audio/volumeDown", "", "")
convertCmdToWebOS MuteToggle = ("ssap://audio/setMute", "mute", "true")
convertCmdToWebOS MediaPlay  = ("ssap://media.controls/play", "", "")
convertCmdToWebOS MediaPause = ("ssap://media.controls/pause", "", "")
convertCmdToWebOS MediaStop  = ("ssap://media.controls/stop", "", "")
convertCmdToWebOS _          = ("", "", "")