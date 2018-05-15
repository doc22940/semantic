{-# LANGUAGE GeneralizedNewtypeDeriving, TypeFamilies #-}
module Data.Abstract.Address where

import Data.Abstract.FreeVariables
import Data.Abstract.Module (ModuleInfo)
import Data.Abstract.Package (PackageInfo)
import Data.Semigroup.Reducer
import Data.Semilattice.Lower
import Data.Set as Set
import Prologue

-- | An abstract address with a @location@ pointing to a variable of type @value@.
newtype Address location value = Address { unAddress :: location }
  deriving (Eq, Ord)

instance Eq   location => Eq1   (Address location) where liftEq          _ a b = unAddress a    ==     unAddress b
instance Ord  location => Ord1  (Address location) where liftCompare     _ a b = unAddress a `compare` unAddress b
instance Show location => Show1 (Address location) where liftShowsPrec _ _     = showsPrec

instance Show location => Show (Address location value) where
  showsPrec d = showsPrec d . unAddress


class Location location where
  -- | The type into which stored values will be written for a given location type.
  type family Cell location :: * -> *


-- | 'Precise' models precise store semantics where only the 'Latest' value is taken. Everything gets it's own address (always makes a new allocation) which makes for a larger store.
newtype Precise = Precise { unPrecise :: Int }
  deriving (Eq, Ord)

instance Location Precise where
  type Cell Precise = Latest

instance Show Precise where
  showsPrec d = showsUnaryWith showsPrec "Precise" d . unPrecise


-- | 'Monovariant' models using one address for a particular name. It trackes the set of values that a particular address takes and uses it's name to lookup in the store and only allocation if new.
newtype Monovariant = Monovariant { unMonovariant :: Name }
  deriving (Eq, Ord)

instance Location Monovariant where
  type Cell Monovariant = All

instance Show Monovariant where
  showsPrec d = showsUnaryWith showsPrec "Monovariant" d . unName . unMonovariant


data Located location = Located
  { location        :: location
  , locationPackage :: {-# UNPACK #-} !PackageInfo
  , locationModule  :: !ModuleInfo
  }
  deriving (Eq, Ord, Show)

instance Location (Located location) where
  type Cell (Located location) = Cell location


-- | A cell holding a single value. Writes will replace any prior value.
--   This is isomorphic to 'Last' from Data.Monoid, but is more convenient
--   because it has a 'Reducer' instance.
newtype Latest value = Latest { unLatest :: Maybe value }
  deriving (Eq, Foldable, Functor, Lower, Ord, Traversable)

instance Semigroup (Latest value) where
  a <> Latest Nothing = a
  _ <> b              = b

-- | 'Option' semantics rather than that of 'Maybe', which is broken.
instance Monoid (Latest value) where
  mappend = (<>)
  mempty  = Latest Nothing

instance Reducer value (Latest value) where
  unit = Latest . Just

instance Show value => Show (Latest value) where
  showsPrec d = showsPrec d . unLatest


newtype All value = All { unAll :: Set value }
  deriving (Eq, Foldable, Lower, Monoid, Ord, Reducer value, Semigroup)

instance Show value => Show (All value) where
  showsPrec d = showsPrec d . Set.toList . unAll
