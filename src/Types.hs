--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

module Types
  ( TVCommand(..)
  , AppID(..)
  ) where

import Data.Aeson (ToJSON(..), Value(String))

-- | Definisi tipe data perintah TV by Mr.Rm19 
data TVCommand
  = PowerToggle     
  | VolumeUp        
  | VolumeDown     
  | MuteToggle     
  | MoveUp          
  | MoveDown       
  | MoveLeft      
  | MoveRight     
  | ClickOK        
  | GoBack         
  | GoHome
  | ChannelUp       
  | ChannelDown   
  | MediaPlay      
  | MediaPause      
  | MediaStop       
  | LaunchApp !AppID
  | ShowToast !String
  | Reboot          
  | Panic           
  deriving (Show, Eq)

-- | ID Aplikasi standar untuk shortcut cepat
data AppID = YouTube | Netflix | Spotify | PrimeVideo deriving (Show, Eq)

instance ToJSON AppID where
  toJSON YouTube    = String "youtube"
  toJSON Netflix    = String "netflix"
  toJSON Spotify    = String "spotify"
  toJSON PrimeVideo = String "primevideo"