{-# LANGUAGE MagicHash, UnboxedTuples, GHCForeignImportPrim, UnliftedFFITypes, BangPatterns #-}
-- | This module allows for the (obviously unsafe) overwriting of one haskell value with another.
module UnsafeSequence where

import GHC.IO
import GHC.Prim
import GHC.Exts

foreign import prim "newHolezh" newHole# :: Int# -> (# Any #)
foreign import prim "setHolezh" setHole# :: Any -> Any -> (##)
foreign import prim "unsafeSetFieldzh" unsafeSetField# :: Int# -> Any -> Any -> (##)
foreign import prim "unsafeGetFieldzh" unsafeGetField# :: Int# -> Any -> (# Any #)

-- | Allocate a value that can be overwritten *once* with @setHole@.
newHole :: IO a
newHole = case newHole# 0# of
  (# x #) -> return (unsafeCoerce# x)
{-# INLINEABLE newHole #-}

-- Set the value of something allocated with @newHole@
setHole :: a -> a -> IO ()
setHole x y = case setHole# (unsafeCoerce# x :: Any) (unsafeCoerce# y :: Any) of
  (##) -> return ()
{-# INLINEABLE setHole #-}

-- Set the value of a certain constructor field.
-- You'd better be careful that it isn't being shared
unsafeSetField :: Int -> a -> b -> IO ()
unsafeSetField (I# i) !x y = case unsafeSetField# i (unsafeCoerce# x :: Any) (unsafeCoerce# y :: Any) of
  (##) -> return ()
{-# INLINEABLE unsafeSetField #-}

unsafeGetField :: Int -> a -> IO b
unsafeGetField (I# i) !x = case unsafeGetField# i (unsafeCoerce# x :: Any) of
  (# y #) -> return (unsafeCoerce# y)
{-# INLINEABLE unsafeGetField #-}

-- Sequence implemented in terms of unsafeSetField
sequenceU :: [IO a] -> IO [a]
sequenceU [] = return []
sequenceU (mx0:xs0) = do
    x0 <- mx0
    let front = x0:[]
    go front xs0
    return front
  where
  go back [] = return ()
  go back (mx:xs) = do
    x <- mx
    let back' = x:[]
    unsafeSetField 1 back back'
    go back' xs
{-# INLINEABLE sequenceU #-}

-- Sequence implemented in terms of holes
sequenceH :: [IO a] -> IO [a]
sequenceH xs0 = do
    front <- newHole
    go front xs0
    return front
  where
  go back [] = setHole back []
  go back (mx:xs) = do
    x <- mx
    back' <- newHole
    setHole back (x:back')
    go back' xs
{-# INLINEABLE sequenceH #-}

-- Sequence using unpacking of the IO monad,
-- from http://neilmitchell.blogspot.co.uk/2015/09/making-sequencemapm-for-io-take-o1-stack.html
sequenceIO :: [IO a] -> IO [a]
sequenceIO xs = do
    ys <- IO $ \r -> (# r, apply r xs #)
    evaluate $ demand ys
    return ys
  where
  apply r [] = []
  apply r (IO x:xs) = case x r of
      (# r, y #) -> y : apply r xs

  demand [] = ()
  demand (x:xs) = demand xs
{-# INLINEABLE sequenceIO #-}

