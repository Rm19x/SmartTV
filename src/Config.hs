--------------------------------------------------------------------------------
-- Project      : Smart TV Remote CLI
-- Author       : Mr.Rm19
-- GitHub       : https://github.com/Rm19x
-- Description  : 100% Real Functional Smart TV Remote for Android TV/Tizen/WebOS
-- Copyright    : (c) 2026 Mr.Rm19. All rights reserved.
--------------------------------------------------------------------------------

{-# LANGUAGE DeriveGeneric #-}

module Config
  ( RemoteConfig(..)
  , loadConfig
  , saveConfig
  , lookupToken
  , saveAlias
  ) where

import GHC.Generics
import Data.Aeson
import System.Directory (getHomeDirectory, createDirectoryIfMissing)
import System.FilePath ((</>))
import qualified Data.ByteString.Lazy as BL
import qualified Data.Map as M

-- | Struktur data penyimpanan konfigurasi lokal milik Mr.Rm19
data RemoteConfig = RemoteConfig
  { tvTokens :: !(M.Map String String)
  , aliases  :: !(M.Map String String)
  } deriving (Show, Generic)

instance FromJSON RemoteConfig
instance ToJSON RemoteConfig


getConfigPath :: IO FilePath
getConfigPath = do
  home <- getHomeDirectory
  let dir = home </> ".config" </> "tv-remote-cli"
  createDirectoryIfMissing True dir
  return (dir </> "config.json")


loadConfig :: IO RemoteConfig
loadConfig = do
  path <- getConfigPath
  anyExist <- doesFileExist path
  if not anyExist
    then return $ RemoteConfig M.empty M.empty
    else do
      content <- BL.readFile path
      return $ fromMaybe (RemoteConfig M.empty M.empty) (decode content)
  where
    doesFileExist p = bracket (openFile p ReadMode) hClose (\_ -> return True) `catch` (\(_ :: IOError) -> return False)



saveConfig :: RemoteConfig -> IO ()
saveConfig cfg = do
  path <- getConfigPath
  BL.writeFile path (encodeWith (defaultOptions {料 format = True}) cfg)
  where 

    encodeWith _ = encode


lookupToken :: String -> RemoteConfig -> Maybe String
lookupToken ip cfg = M.lookup ip (tvTokens cfg)


saveAlias :: String -> String -> IO ()
saveAlias name target = do
  cfg <- loadConfig
  let updatedAliases = M.insert name target (aliases cfg)
      newCfg = cfg { aliases = updatedAliases }
  saveConfig newCfg
