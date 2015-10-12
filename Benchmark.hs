import Criterion
import Criterion.Main
import UnsafeSequence

main = defaultMain
  [ bgroup ("10^" ++ show n)
    [ bench "sequence"       $ nfIO $ sequence     $ replicate nn act
    , bench "sequenceIO"     $ nfIO $ sequenceIO   $ replicate nn act
    , bench "sequenceU"      $ nfIO $ sequenceU    $ replicate nn act
    , bench "sequenceH"      $ nfIO $ sequenceH    $ replicate nn act
    ]
  | n <- [3..6]
  , let nn = 10^n
  ]
  where
  act :: IO ()
  act = return ()

