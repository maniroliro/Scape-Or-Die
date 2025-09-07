local lib = require(script.lib)
local types = require(script.Types)
local utils = require(script.Utils)
local remotes = require(script.Remotes)

---------ClientModuleUtils Types ---------------

export type Cinematic = lib.Cinematic
export type CinematicStartArgs = lib.CinematicStartArgs

export type Icon = lib.Icon

export type WrappedGuiButton = lib.WrappedGuiButton

export type WrappedGuiImage = lib.WrappedGuiImage

export type WrappedGuiObject = lib.WrappedGuiObject

export type WrappedGuiStroke = lib.WrappedGuiStroke

export type WrappedTextLabel = lib.WrappedTextLabel

export type WrappedSurfaceGui = lib.WrappedSurfaceGui

export type WrappedBillboardGui = lib.WrappedBillboardGui

export type InterfaceEffect = lib.InterfaceEffect

export type LightningBolt = lib.LightningBolt
export type LightningSparks = lib.LightningSparks
export type LightningExplosion = lib.LightningExplosion

export type ParallaxWindow = lib.ParallaxWindow

export type StreamableType = lib.StreamableType

export type WindLineCreator = lib.WindLineCreator
export type WindLineCreatorParams = lib.WindLineCreatorParams

export type WindShakeSettings = lib.WindShakeSettings

export type GamepadType = lib.GamepadType
export type MouseType = lib.MouseType
export type KeyboardType = lib.KeyboardType
export type TouchType = lib.TouchType

export type screen3D = lib.screen3D
export type screenGen = lib.screenGen
export type component3D = lib.component3D
export type componentGen = lib.componentGen

-------------FunctionUtils Types-----------------

export type Schema = lib.Schema

-------------ModuleUtils Types-------------------

export type Packet<A... = (), B... = ()> = lib.Packet<A..., B...>
export type Lottery = lib.Lottery
export type LotteryTicket = lib.LotteryTicket

export type LessSimpleZone<U, T...> = lib.LessSimpleZone<U, T...>
export type Zone = lib.Zone

export type ZoneQueryOptions = lib.ZoneQueryOptions
export type ZoneBox = lib.ZoneBox

export type Future<T...> = lib.Future<T...>

export type RateLimiter = lib.RateLimiter

export type PromiseAny = lib.PromiseAny
export type Promise<T...> = lib.Promise<T...>

export type SchedulerType = lib.SchedulerType

-- Func is the function passed to :Once() or :Connect(). ReturnVals is the data returned from :Wait() or passed to :Fire()
-- The args in Func should match ReturnVals!
--export type SignalType<Func, ReturnVals...> = lib.SignalType<Func, ReturnVals...>
-- If you don't want to bother defining argument names:
export type Signal<func, ReturnVals...> = lib.Signal<func, ReturnVals...>
--export type GenericSignal = lib.GenericSignal
--export type SignalConnection = lib.SignalConnection

export type TroveType = lib.TroveType

export type OctreeType = lib.OctreeType
export type OctreeNodeType = lib.OctreeNodeType

export type TimerType = lib.TimerType

export type ShakeType = lib.ShakeType
export type ShakeProperties = lib.ShakeProperties

export type PartCache = lib.PartCache

export type CacheType = lib.CacheType

export type Spring<T> = lib.Spring<T>

export type Proxy<T = { [any]: any }> = lib.Proxy<T>

export type Binder = lib.Binder

export type LoggerType = lib.LoggerType

export type Quaternion = lib.Quaternion
export type QuaternionSpring = lib.QuaternionSpring

-- Typed Remotes & Bindables
export type RemoteEvent<Server..., Client...> = lib.RemoteEvent<Server..., Client...>
export type RemoteFunction<Send..., Receive...> = lib.RemoteFunction<Send..., Receive...>
export type BindableEvent<Send...> = lib.BindableEvent<Send...>
export type BindableFunction<Send..., Receive...> = lib.BindableFunction<Send..., Receive...>

export type AdjustmentPool = lib.AdjustmentPool
export type AcceptedPoolValues = lib.AcceptedPoolValues

export type PredicateManager = lib.PredicateManager
export type CallbackManager = lib.CallbackManager

export type TimeKeeper = lib.TimeKeeper
export type UniversalTimestamp = lib.UniversalTimestamp

export type PathfinderInstance = lib.PathfinderInstance

export type Batcher = lib.Batcher

export type BezierCurve = lib.BezierCurve

export type DataCatalog<T> = lib.DataCatalog<T>

export type RandomRotator = lib.RandomRotator
export type RotationConfig = lib.RotationConfig

export type Respawner = lib.Respawner

export type DynamicOctree = lib.DynamicOctree

-------------Game Utils-------------------

export type ReplicableInstance = utils.ReplicableInstance

-------------Game Types-------------------

local module = {
	ClientModuleUtils = lib.ClientModuleUtils,
	FunctionUtils = lib.FunctionUtils,
	ModuleUtils = lib.ModuleUtils,
	Types = types,
	Utils = utils,
	Remotes = remotes,
}

return module
