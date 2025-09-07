local ClientModuleUtils = require(script.ClientModuleUtils)
local FunctionUtils = require(script.FunctionUtils)
local ModuleUtils = require(script.ModuleUtils)

---------ClientModuleUtils Types ---------------

export type Cinematic = ClientModuleUtils.Cinematic
export type CinematicStartArgs = ClientModuleUtils.CinematicStartArgs

export type Icon = ClientModuleUtils.Icon

export type WrappedGuiButton = ClientModuleUtils.WrappedGuiButton

export type WrappedGuiImage = ClientModuleUtils.WrappedGuiImage

export type WrappedGuiObject = ClientModuleUtils.WrappedGuiObject

export type WrappedGuiStroke = ClientModuleUtils.WrappedGuiStroke

export type WrappedTextLabel = ClientModuleUtils.WrappedTextLabel

export type WrappedSurfaceGui = ClientModuleUtils.WrappedSurfaceGui

export type WrappedBillboardGui = ClientModuleUtils.WrappedBillboardGui

export type InterfaceEffect = ClientModuleUtils.InterfaceEffect

export type LightningBolt = ClientModuleUtils.LightningBolt
export type LightningSparks = ClientModuleUtils.LightningSparks
export type LightningExplosion = ClientModuleUtils.LightningExplosion

export type ParallaxWindow = ClientModuleUtils.ParallaxWindow

export type StreamableType = ClientModuleUtils.StreamableType

export type WindLineCreator = ClientModuleUtils.WindLineCreator
export type WindLineCreatorParams = ClientModuleUtils.WindLineCreatorParams

export type WindShakeSettings = ClientModuleUtils.WindShakeSettings

export type GamepadType = ClientModuleUtils.GamepadType
export type MouseType = ClientModuleUtils.MouseType
export type KeyboardType = ClientModuleUtils.KeyboardType
export type TouchType = ClientModuleUtils.TouchType

export type screen3D = ClientModuleUtils.screen3D
export type screenGen = ClientModuleUtils.screenGen
export type component3D = ClientModuleUtils.component3D
export type componentGen = ClientModuleUtils.componentGen

-------------FunctionUtils Types-----------------

export type Schema = FunctionUtils.Schema

-------------ModuleUtils Types-------------------

export type Packet<A... = (), B... = ()> = ModuleUtils.Packet<A..., B...>

export type Lottery = ModuleUtils.Lottery
export type LotteryTicket = ModuleUtils.LotteryTicket

export type LessSimpleZone<U, T...> = ModuleUtils.LessSimpleZone<U, T...>
export type Zone = ModuleUtils.Zone

export type ZoneQueryOptions = ModuleUtils.ZoneQueryOptions
export type ZoneBox = ModuleUtils.ZoneBox

export type Future<T...> = ModuleUtils.Future<T...>

export type RateLimiter = ModuleUtils.RateLimiter

export type PromiseAny = ModuleUtils.PromiseAny
export type Promise<T...> = ModuleUtils.Promise<T...>

export type SchedulerType = ModuleUtils.SchedulerType

-- Func is the function passed to :Once() or :Connect(). ReturnVals is the data returned from :Wait() or passed to :Fire()
-- The args in Func should match ReturnVals!
--export type SignalType<Func, ReturnVals...> = ModuleUtils.SignalType<Func, ReturnVals...>
-- If you don't want to bother defining argument names:
export type Signal<Func, ReturnVals...> = ModuleUtils.Signal<Func, ReturnVals...>
--export type GenericSignal = ModuleUtils.GenericSignal
--export type SignalConnection = ModuleUtils.SignalConnection

export type TroveType = ModuleUtils.TroveType

export type OctreeType = ModuleUtils.OctreeType
export type OctreeNodeType = ModuleUtils.OctreeNodeType

export type TimerType = ModuleUtils.TimerType

export type ShakeType = ModuleUtils.ShakeType
export type ShakeProperties = ModuleUtils.ShakeProperties

export type PartCache = ModuleUtils.PartCache

export type CacheType = ModuleUtils.CacheType

-- Importar tipo nlerpable diretamente do Spring
export type Spring<T> = ModuleUtils.Spring<T>

export type Proxy<T = { [any]: any }> = ModuleUtils.Proxy<T>

export type Binder = ModuleUtils.Binder

export type LoggerType = ModuleUtils.LoggerType

export type Quaternion = ModuleUtils.Quaternion
export type QuaternionSpring = ModuleUtils.QuaternionSpring

-- Typed Remotes & Bindables
export type RemoteEvent<Server..., Client...> = ModuleUtils.RemoteEvent<Server..., Client...>
export type RemoteFunction<Send..., Receive...> = ModuleUtils.RemoteFunction<Send..., Receive...>
export type BindableEvent<Send...> = ModuleUtils.BindableEvent<Send...>
export type BindableFunction<Send..., Receive...> = ModuleUtils.BindableFunction<Send..., Receive...>

export type AdjustmentPool = ModuleUtils.AdjustmentPool
export type AcceptedPoolValues = ModuleUtils.AcceptedPoolValues

export type PredicateManager = ModuleUtils.PredicateManager
export type CallbackManager = ModuleUtils.CallbackManager

export type TimeKeeper = ModuleUtils.TimeKeeper
export type UniversalTimestamp = ModuleUtils.UniversalTimestamp

export type PathfinderInstance = ModuleUtils.PathfinderInstance

export type Batcher = ModuleUtils.Batcher

export type BezierCurve = ModuleUtils.BezierCurve

export type DataCatalog<T> = ModuleUtils.DataCatalog<T>

export type RandomRotator = ModuleUtils.RandomRotator
export type RotationConfig = ModuleUtils.RotationConfig

export type Respawner = ModuleUtils.Respawner

export type DynamicOctree = ModuleUtils.DynamicOctree

local module = {
	ClientModuleUtils = ClientModuleUtils,
	FunctionUtils = FunctionUtils,
	ModuleUtils = ModuleUtils,
}

return module
