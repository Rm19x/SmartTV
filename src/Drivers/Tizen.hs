--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

{-# LANGUAGE OverloadedStrings #-}

module Drivers.Tizen
  ( sendTizenCommand
  ) where

import Types
import Network.WebSockets
import Wuss (runSecureClient)
import Data.Aeson
import qualified Data.Text as T
import qualified Data.ByteString.Lazy.Char8 as BL


sendTizenCommand :: String -> TVCommand -> Maybe String -> IO ()
sendTizenCommand ip cmd maybeToken = do
  let port = 8002

      tokenStr = maybe "" ("&token=" ++) maybeToken
      path = "/api/v2/channels/samsung.remote.control?name=MrRm19Remote" ++ tokenStr
      
  putStrLn $ "[*] Membuka jalur aman WebSocket ke Samsung TV (" ++ ip ++ ")..."
  runSecureClient ip port path $ \conn -> do

    _ <- receiveData conn :: IO BL.ByteString
    
    let keyName = convertCmdToTizen cmd
    case keyName of
      Just kn -> do

        let packet = object 
              [ "method" .= ("ms.remote.control" :: T.Text)
              , "params" .= object 
                  [ "Cmd" .= ("Click" :: T.Text)
                  , "DataOfCmd" .= kn
                  , "Option" .= ("false" :: T.Text)
                  , "TypeOfCmd" .= ("遙控器鍵值" :: T.Text) -- Tipe input standar Tizen
                  ]
              ]
        sendBinaryData conn (encode packet)
        putStrLn $ "[+] [Tizen] Sukses mengirim tombol " ++ T.unpack kn ++ " ke TV."
      Nothing -> return ()

-- | Pemetaan kode tombol remote resmi Samsung Tizen OS
convertCmdToTizen :: TVCommand -> Maybe T.Text
convertCmdToTizen PowerToggle = Just "KEY_POWER"
convertCmdToTizen VolumeUp    = Just "KEY_VOLUP"
convertCmdToTizen VolumeDown  = Just "KEY_VOLDOWN"
convertCmdToTizen MuteToggle  = Just "KEY_MUTE"
convertCmdToTizen MoveUp      = Just "KEY_UP"
convertCmdToTizen MoveDown    = Just "KEY_DOWN"
convertCmdToTizen MoveLeft    = Just "KEY_LEFT"
convertCmdToTizen MoveRight   = Just "KEY_RIGHT"
convertCmdToTizen ClickOK     = Just "KEY_ENTER"
convertCmdToTizen GoBack      = Just "KEY_RETURN"
convertCmdToTizen GoHome      = Just "KEY_HOME"
convertCmdToTizen ChannelUp   = Just "KEY_CHUP"
convertCmdToTizen ChannelDown = Just "KEY_CHDOWN"
convertCmdToTizen MediaPlay   = Just "KEY_PLAY"
convertCmdToTizen MediaPause  = Just "KEY_PAUSE"
convertCmdToTizen MediaStop   = Just "KEY_STOP"
convertCmdToTizen _           = Nothing