#!/usr/bin/env python3
import logging
from typing import Dict, Tuple, Union

from pymodbus.constants import Endian

from time import sleep
from dataclass_utils import dataclass_from_dict
from modules.common import modbus
from modules.common.component_state import BatState
from modules.common.component_type import ComponentDescriptor
from modules.common.fault_state import ComponentInfo
from modules.common.modbus import ModbusDataType
from modules.common.simcount import SimCounter
from modules.common.store import get_bat_value_store
from modules.devices.solaredge.config import SolaredgeBatSetup

log = logging.getLogger(__name__)

FLOAT32_UNSUPPORTED = -0xffffff00000000000000000000000000


class SolaredgeBat:
    def __init__(self,
                 device_id: int,
                 component_config: Union[Dict, SolaredgeBatSetup],
                 tcp_client: modbus.ModbusTcpClient_) -> None:
        self.__device_id = device_id
        self.component_config = dataclass_from_dict(SolaredgeBatSetup, component_config)
        self.__tcp_client = tcp_client
        self.sim_counter = SimCounter(self.__device_id, self.component_config.id, prefix="speicher")
        self.store = get_bat_value_store(self.component_config.id)
        self.component_info = ComponentInfo.from_component_config(self.component_config)

    def update(self) -> None:
        self.store.set(self.read_state())

    def read_state(self):
        power, soc = self.get_values()
        imported, exported = self.get_imported_exported(power)
        return BatState(
            power=power,
            soc=soc,
            imported=imported,
            exported=exported
        )

    def get_values(self) -> Tuple[float, float]:
        unit = self.component_config.configuration.modbus_id
        soc = self.__tcp_client.read_holding_registers(
            62852, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        power = self.__tcp_client.read_holding_registers(
            62836, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        if power == FLOAT32_UNSUPPORTED:
            power = 0
        return power, soc

    def get_imported_exported(self, power: float) -> Tuple[float, float]:
        return self.sim_counter.sim_count(power)

    def discharge_limit(self, aktiv: int, power: int):
        unit = self.component_config.configuration.modbus_id        

        storage = self.__tcp_client.read_holding_registers(
            0xE004, ModbusDataType.UINT_16, unit=unit)
        if aktiv:
            log.debug("---------> aktiv!!")
            # 1: Maximize Self Consumption oder 4:Remote
            self.__tcp_client.write_single_register(
                0xE004, 4, ModbusDataType.INT_16, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
            self.__tcp_client.write_single_register(
                0xE00A, 7, ModbusDataType.INT_16, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)        
            self.__tcp_client.write_single_register(
                0xE00B, 120, ModbusDataType.INT_32, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
            self.__tcp_client.write_single_register(
                0xE00D, 7, ModbusDataType.INT_16, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
            self.__tcp_client.write_single_register(
                0xE010, power, ModbusDataType.FLOAT_32, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
            log.debug("------> SolarEdge Remotebetrieb einschalten und Discharge Limit auf %d W", power)
        else:
            log.debug("---------> inaktiv!!")
            # wenn auf Remote
            if storage == 4:
                # 1: Maximize Self Consumption oder 4:Remote
                self.__tcp_client.write_single_register(
                    0xE004, 1, ModbusDataType.INT_16, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
                log.debug("------> SolarEdge Remotebetrieb abschalten!")        
        
        """
        reg = 0xF002
        val = 0.0
        ret = self.__tcp_client.write_single_register(
            reg, val, ModbusDataType.FLOAT_32, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
        log.debug("------> geschrieben!!! CosPhi %X: %f %r",reg, val, ret)
        """
        """
        reg = 0xF104
        val = 3
        ret = self.__tcp_client.write_single_register(
            reg, val, ModbusDataType.INT_32, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
        log.debug("------> geschrieben!!! ReactivePwrConfig %X: %d %r",reg, val, ret)
        
        reg = 0xF100
        val = 1
        ret = self.__tcp_client.write_single_register(
            reg, val, ModbusDataType.INT_16, byteorder=Endian.Big, wordorder=Endian.Little, unit=unit)
        log.debug("------> geschrieben!!! Commit Power Control Settings %X: %d %r",reg, val, ret)
        """

        reg = 0xF142
        val_i32 = self.__tcp_client.read_holding_registers(
           reg, ModbusDataType.INT_32, wordorder=Endian.Little, unit=unit)
        log.debug("-----> AdvancedPwrControlEn %X: %ld", reg, val_i32)

        reg = 0xF104
        val_i32 = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.INT_32, wordorder=Endian.Little, unit=unit)
        log.debug("-----> ReactivePwrConfig %X: %ld", reg, val_i32)
        
        reg = 0xE004
        storage = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.UINT_16, unit=unit)
        log.debug("-----> Control Mode %X: %d",reg, storage)
        """
        reg = 0xF002
        power = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        log.debug("---> CosPhi %X: %1.2f", reg, power)
        """
        reg = 0xE010
        power = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        log.debug("---> Discharge Limit %X: %1.2f", reg, power)
        
        reg = 0xE00E
        power = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.FLOAT_32, wordorder=Endian.Little, unit=unit)
        log.debug("---> Charge Limit %X: %1.2f", reg, power)
        
        reg = 0xE00A
        storage = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.UINT_16, unit=unit)
        log.debug("---> Storage Charge/Discharge Default Mode %X: %d",reg, storage)
        
        reg = 0xE00D
        storage = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.UINT_16, unit=unit)
        log.debug("---> Remote Control Command Mode %X: %d",reg, storage)
        
        reg = 0xE00B
        storage = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.INT_32, wordorder=Endian.Little, unit=unit)
        log.debug("---> Remote Control Command Timeout %X: %d",reg, storage)
        """
        reg = 0xF001
        storage = self.__tcp_client.read_holding_registers(
            reg, ModbusDataType.UINT_16, unit=unit)
        log.debug("---> Active Power Limit in prozent %X: %d",reg, storage)
        """
component_descriptor = ComponentDescriptor(configuration_factory=SolaredgeBatSetup)
