module Paths_simple_expr (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/wolfgang/.cabal/bin"
libdir     = "/home/wolfgang/.cabal/lib/i386-linux-ghc-7.6.3/simple-expr-0.1.0.0"
datadir    = "/home/wolfgang/.cabal/share/i386-linux-ghc-7.6.3/simple-expr-0.1.0.0"
libexecdir = "/home/wolfgang/.cabal/libexec"
sysconfdir = "/home/wolfgang/.cabal/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "simple_expr_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "simple_expr_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "simple_expr_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "simple_expr_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "simple_expr_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
