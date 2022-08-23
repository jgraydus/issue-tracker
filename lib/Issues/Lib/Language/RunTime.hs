module Issues.Lib.Language.RunTime where

import           Control.Monad.IO.Class (MonadIO)
import           Control.Monad.Except (ExceptT, MonadError)
import           Control.Monad.Reader (ReaderT, runReaderT)
import           Servant.Server (Handler(..), ServerError)

import           Issues.Lib.Config (ApplicationConfig)
import           Issues.Lib.Language.AppL
import           Issues.Lib.Logger (Logger)
import           Issues.Lib.Model

data RunTime = RunTime
  { runApp :: forall m a. (MonadIO m, MonadError ServerError m) => Logger -> User -> App a -> m a
  }

type AppHandler = ReaderT (RunTime, Logger, ApplicationConfig) (ExceptT ServerError IO)

runAppHandler :: RunTime -> Logger -> ApplicationConfig -> AppHandler a -> Handler a
runAppHandler rt logger config h = Handler $ runReaderT h (rt, logger, config)

