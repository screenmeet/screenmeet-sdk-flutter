package com.screenmeet.sdk_live_flutter_plugin.utils

import kotlin.collections.ArrayList

class ConstraintsArray {

    private val mArray: ArrayList<Any>

    constructor() {
        mArray = ArrayList()
    }

    constructor(array: ArrayList<Any>) {
        mArray = array
    }

    fun size(): Int {
        return mArray.size
    }

    fun getBoolean(index: Int): Boolean {
        return mArray[index] as Boolean
    }

    fun getDouble(index: Int): Double {
        return mArray[index] as Double
    }

    fun getInt(index: Int): Int {
        return mArray[index] as Int
    }

    fun getString(index: Int): String {
        return mArray[index] as String
    }

    fun getByte(index: Int): Array<Byte> {
        return mArray[index] as Array<Byte>
    }

    fun getArray(index: Int): ConstraintsArray {
        return ConstraintsArray(mArray[index] as ArrayList<Any>)
    }

    fun getMap(index: Int): ConstraintsMap {
        return ConstraintsMap(mArray[index] as MutableMap<String, Any?>)
    }

    fun getType(index: Int): ObjectType {
        val any = mArray[index]
        if (any is Boolean) {
            return ObjectType.Boolean
        } else if (any is Double ||
            any is Float ||
            any is Int
        ) {
            return ObjectType.Number
        } else if (any is String) {
            return ObjectType.String
        } else if (any is ArrayList<*>) {
            return ObjectType.Array
        } else if (any is Map<*, *>) {
            return ObjectType.Map
        } else if (any is Byte) {
            return ObjectType.Byte
        }
        return ObjectType.Null
    }

    fun toArrayList(): ArrayList<Any> {
        return mArray
    }

    fun pushBoolean(value: Boolean) {
        mArray.add(value)
    }

    fun pushDouble(value: Double) {
        mArray.add(value)
    }

    fun pushInt(value: Int) {
        mArray.add(value)
    }

    fun pushString(value: String) {
        mArray.add(value)
    }

    fun pushArray(array: ConstraintsArray) {
        mArray.add(array.toArrayList())
    }

    fun pushByte(value: ByteArray) {
        mArray.add(value)
    }

    fun pushMap(map: ConstraintsMap) {
        mArray.add(map.toMap())
    }
}