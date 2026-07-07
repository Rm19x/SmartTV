--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

module Drivers.AndroidTV
  ( sendAndroidCommand
  ) where

import Network.Socket
import Types
import Control.Exception (bracket)
import qualified Data.ByteString.Char8 as BC


sendAndroidCommand :: String -> TVCommand -> IO ()
sendAndroidCommand ip cmd = do
  let port = "5555" -- Port standar ADB over Wi-Fi
  addrInfos <- getAddrInfo (Just defaultHints { addrSocketType = Stream }) (Just ip) (Just port)
  case addrInfos of
    [] -> putStrLn $ "[-] Gagal mendapatkan alamat IP Android TV: " ++ ip
    (serverAddr:_) -> bracket
      (socket (addrFamily serverAddr) Stream defaultProtocol)
      close
      (\sock -> do
         connect sock (addrAddress serverAddr)
         let rawPayload = convertCmdToAndroid cmd
         case rawPayload of
           Just payload -> do
             _ <- send sock (BC.pack payload)
             putStrLn $ "[+] [Android TV] Perintah " ++ show cmd ++ " berhasil dikirim ke " ++ ip
           Nothing -> return ()
      )


convertCmdToAndroid :: TVCommand -> Maybe String
convertCmdToAndroid PowerToggle = Just "shell input keyevent 26\n"
convertCmdToAndroid VolumeUp    = Just "shell input keyevent 24\n"
convertCmdToAndroid VolumeDown  = Just "shell input keyevent 25\n"
convertCmdToAndroid MuteToggle  = Just "shell input keyevent 164\n"
convertCmdToAndroid MoveUp      = Just "shell input keyevent 19\n"
convertCmdToAndroid MoveDown    = Just "shell input keyevent 20\n"
convertCmdToAndroid MoveLeft    = Just "shell input keyevent 21\n"
convertCmdToAndroid MoveRight   = Just "shell input keyevent 22\n"
convertCmdToAndroid ClickOK     = Just "shell input keyevent 66\n"
convertCmdToAndroid GoBack      = Just "shell input keyevent 4\n"
convertCmdToAndroid GoHome      = Just "shell input keyevent 3\n"
convertCmdToAndroid ChannelUp   = Just "shell input keyevent 166\n"
convertCmdToAndroid ChannelDown = Just "shell input keyevent 167\n"
convertCmdToAndroid MediaPlay   = Just "shell input keyevent 126\n"
convertCmdToAndroid MediaPause  = Just "shell input keyevent 127\n"
convertCmdToAndroid MediaStop   = Just "shell input keyevent 86\n"
convertCmdToAndroid Reboot      = Just "reboot\n"
convertCmdToAndroid Panic       = Just "disconnect\n"
convertCmdToAndroid _           = Nothing 
