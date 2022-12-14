module IssueTracker.Lib.Language.RunTime where

import           Control.Monad.IO.Class (MonadIO)
import           Control.Monad.Except (ExceptT, MonadError)
import           Control.Monad.Reader (ReaderT, runReaderT)
import           Servant.Server (Handler(..), ServerError)

import           IssueTracker.Lib.Config (ApplicationConfig)
import           IssueTracker.Lib.Language.AppL
import           IssueTracker.Lib.Logger (Logger)
import           IssueTracker.Lib.Model

data RunTime = RunTime
  { runApp :: forall m a. (MonadIO m, MonadError ServerError m) => Logger -> User -> App a -> m a
  }

type AppHandler = ReaderT (RunTime, Logger, ApplicationConfig) (ExceptT ServerError IO)

runAppHandler :: RunTime -> Logger -> ApplicationConfig -> AppHandler a -> Handler a
runAppHandler rt logger config h = Handler $ runReaderT h (rt, logger, config)

