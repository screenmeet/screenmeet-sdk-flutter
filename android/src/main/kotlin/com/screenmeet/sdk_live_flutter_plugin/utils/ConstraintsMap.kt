package com.screenmeet.sdk_live_flutter_plugin.utils

import java.lang.IllegalArgumentException
import java.util.ArrayList
import java.util.HashMap

class ConstraintsMap {

    private val mMap: MutableMap<String, Any?>

    constructor() {
        mMap = HashMap()
    }

    constructor(map: MutableMap<String, Any?>) {
        mMap = map
    }

    fun toMap(): Map<String, Any?> {
        return mMap
    }

    fun hasKey(name: String): Boolean {
        return mMap.containsKey(name)
    }

    fun isNull(name: String): Boolean {
        return mMap[name] == null
    }

    fun getBoolean(name: String): Boolean {
        return mMap[name] as Boolean
    }

    fun getDouble(name: String): Double {
        return mMap[name] as Double
    }

    fun getInt(name: String): Int {
        return if (getType(name) === ObjectType.String) {
            (mMap[name] as String?)!!.toInt()
        } else mMap[name] as Int
    }

    fun getString(name: String): String? {
        return mMap[name] as String?
    }

    fun getMap(name: String): ConstraintsMap? {
        val value = mMap[name] ?: return null
        return ConstraintsMap(value as MutableMap<String, Any?>)
    }

    private fun getType(name: String): ObjectType {
        return when (val value = mMap[name]) {
            null -> ObjectType.Null
            is Number -> ObjectType.Number
            is String -> ObjectType.String
            is Boolean -> ObjectType.Boolean
            is Map<*, *> -> ObjectType.Map
            is ArrayList<*> -> ObjectType.Array
            is Byte -> ObjectType.Byte
            else -> {
                throw IllegalArgumentException(
                    "Invalid value " + value.toString() + " for key " + name +
                            "contained in ConstraintsMap"
                )
            }
        }
    }

    fun putBoolean(key: String, value: Boolean) {
        mMap[key] = value
    }

    fun putDouble(key: String, value: Double) {
        mMap[key] = value
    }

    fun putInt(key: String, value: Int) {
        mMap[key] = value
    }

    fun putLong(key: String, value: Long) {
        mMap[key] = value
    }

    fun putString(key: String, value: String?) {
        mMap[key] = value
    }

    fun putByte(key: String, value: ByteArray?) {
        mMap[key] = value
    }

    fun putNull(key: String) {
        mMap[key] = null
    }

    fun putMap(key: String, value: Map<String?, Any?>?) {
        mMap[key] = value
    }

    fun merge(value: Map<String, Any?>?) {
        mMap.putAll(value!!)
    }

    fun putArray(key: String, value: ArrayList<Any?>?) {
        mMap[key] = value
    }

    fun getArray(name: String): ConstraintsArray? {
        val value = mMap[name] ?: return null
        return ConstraintsArray(value as ArrayList<Any>)
    }

    fun getListArray(name: String): ArrayList<Any> {
        return mMap[name] as ArrayList<Any>
    }
}