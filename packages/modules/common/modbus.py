#!/usr/bin/env python3
"""Modul für einfache Modbus-Operationen.

Das Modul baut eine Modbus-TCP-Verbindung auf. Es gibt verschiedene Funktionen, um die gelesenen Register zu
formatieren.
"""
import logging
import struct
from enum import Enum
from typing import Callable, Iterable, Union, overload, List

import pymodbus
from pymodbus.client.sync import ModbusTcpClient, ModbusSerialClient
from pymodbus.constants import Endian
from pymodbus.payload import BinaryPayloadDecoder, BinaryPayloadBuilder
from urllib3.util import parse_url

from modules.common.fault_state import FaultState

log = logging.getLogger(__name__)


class ModbusDataType(Enum):
    UINT_8 = 8, "decode_8bit_uint"
    UINT_16 = 16, "decode_16bit_uint"
    UINT_32 = 32, "decode_32bit_uint"
    UINT_64 = 64, "decode_64bit_uint"
    INT_8 = 8, "decode_8bit_int"
    INT_16 = 16, "decode_16bit_int"
    INT_32 = 32, "decode_32bit_int"
    INT_64 = 64, "decode_64bit_int"
    FLOAT_16 = 16, "decode_16bit_float"
    FLOAT_32 = 32, "decode_32bit_float"
    FLOAT_64 = 64, "decode_64bit_float"

    def __init__(self, bits: int, decoding_method: str):
        self.bits = bits
        self.decoding_method = decoding_method


_MODBUS_HOLDING_REGISTER_SIZE = 16
Number = Union[int, float]


class ModbusClient:
    def __init__(self, delegate: Union[ModbusSerialClient, ModbusTcpClient], address: str, port: int = 502):
        self.delegate = delegate
        self.address = address
        self.port = port

    def __enter__(self):
        self.delegate.__enter__()
        return self

    def __exit__(self, exc_type, exc_value, exc_traceback):
        self.delegate.__exit__(exc_type, exc_value, exc_traceback)

    def close_connection(self) -> None:
        try:
            log.debug("Close Modbus TCP connection")
            self.delegate.close()
        except Exception as e:
            raise FaultState.error(__name__+" "+str(type(e))+" " +
                                   str(e)) from e

    def __read_registers(self, read_register_method: Callable,
                         address: int,
                         types: Union[Iterable[ModbusDataType], ModbusDataType],
                         byteorder: Endian = Endian.Big,
                         wordorder: Endian = Endian.Big,
                         **kwargs):
        try:
            multi_request = isinstance(types, Iterable)
            if not multi_request:
                types = [types]

            def divide_rounding_up(numerator: int, denominator: int):
                return -(-numerator // denominator)

            number_of_addresses = sum(divide_rounding_up(
                t.bits, _MODBUS_HOLDING_REGISTER_SIZE) for t in types)
            response = read_register_method(
                address, number_of_addresses, **kwargs)
            if response.isError():
                raise FaultState.error(__name__+" "+str(response))
            decoder = BinaryPayloadDecoder.fromRegisters(response.registers, byteorder, wordorder)
            result = [struct.unpack(">e", struct.pack(">H", decoder.decode_16bit_uint())) if t ==
                      ModbusDataType.FLOAT_16 else getattr(decoder, t.decoding_method)() for t in types]
            return result if multi_request else result[0]
        except pymodbus.exceptions.ConnectionException as e:
            raise FaultState.error(
                "TCP-Client konnte keine Verbindung zu " + str(self.address) + ":" + str(self.port) +
                " aufbauen. Bitte Einstellungen (IP-Adresse, ..) und " + "Hardware-Anschluss prüfen.") from e
        except pymodbus.exceptions.ModbusIOException as e:
            raise FaultState.warning(
                "TCP-Client " + str(self.address) + ":" + str(self.port) +
                " konnte keinen Wert abfragen. Falls vorhanden, parallele Verbindungen, zB. node red," +
                "beenden und bei anhaltender Fehlermeldung Zähler neu starten.") from e
        except Exception as e:
            raise FaultState.error(__name__+" "+str(type(e))+" " +
                                   str(e)) from e

    
    def __write_registers(self, write_register_method: Callable,
                         address: int,
                         value,
                         types: Union[Iterable[ModbusDataType], ModbusDataType],
                         byteorder: Endian = Endian.Big,
                         wordorder: Endian = Endian.Big,
                         **kwargs):
        try:
            multi_request = isinstance(types, Iterable)
            if not multi_request:
                types = [types]
            
            builder = BinaryPayloadBuilder(byteorder=byteorder, wordorder=wordorder)
            for t in types:
                if t == ModbusDataType.INT_16:
                    builder.add_16bit_int(int(value))
                elif t == ModbusDataType.INT_32:
                    builder.add_32bit_int(int(value))                    
                elif t == ModbusDataType.FLOAT_32:
                    builder.add_32bit_float(float(value))
            response = write_register_method(address, builder.to_registers(), **kwargs)
            
            err = response.isError()
            if err:
                raise FaultState.error(__name__+" "+str(response))            
            return not err
        
        except pymodbus.exceptions.ConnectionException as e:
            raise FaultState.error(
                "TCP-Client konnte keine Verbindung zu " + str(self.address) + ":" + str(self.port) +
                " aufbauen. Bitte Einstellungen (IP-Adresse, ..) und " + "Hardware-Anschluss prüfen.") from e
        except pymodbus.exceptions.ModbusIOException as e:
            raise FaultState.warning(
                "TCP-Client " + str(self.address) + ":" + str(self.port) +
                " konnte keinen Wert abfragen. Falls vorhanden, parallele Verbindungen, zB. node red," +
                "beenden und bei anhaltender Fehlermeldung Zähler neu starten.") from e
        except Exception as e:
            raise FaultState.error(__name__+" "+str(type(e))+" " +
                                   str(e)) from e


    @overload
    def read_holding_registers(self, address: int, types: Iterable[ModbusDataType], byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big, **kwargs) -> List[Number]:
        pass

    @overload
    def read_holding_registers(self, address: int, types: ModbusDataType, byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big, **kwargs) -> Number:
        pass

    def read_holding_registers(self, address: int,
                               types: Union[Iterable[ModbusDataType], ModbusDataType],
                               byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big,
                               **kwargs):
        return self.__read_registers(
            self.delegate.read_holding_registers, address, types, byteorder, wordorder, **kwargs
        )

    @overload
    def read_input_registers(self, address: int, types: Iterable[ModbusDataType], byteorder: Endian = Endian.Big,
                             wordorder: Endian = Endian.Big,
                             **kwargs) -> List[Number]:
        pass

    @overload
    def read_input_registers(self, address: int, types: ModbusDataType, byteorder: Endian = Endian.Big,
                             wordorder: Endian = Endian.Big, **kwargs) -> Number:
        pass

    def read_input_registers(self, address: int,
                             types: Union[Iterable[ModbusDataType], ModbusDataType],
                             byteorder: Endian = Endian.Big,
                             wordorder: Endian = Endian.Big,
                             **kwargs):
        return self.__read_registers(self.delegate.read_input_registers, address, types, byteorder, wordorder, **kwargs)


    @overload
    def write_single_register(self, address: int, value, types: Iterable[ModbusDataType], byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big, **kwargs):
        pass

    @overload
    def write_single_register(self, address: int, value, types: ModbusDataType, byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big, **kwargs):
        pass

    def write_single_register(self, address: int,
                               value,
                               types: Union[Iterable[ModbusDataType], ModbusDataType],
                               byteorder: Endian = Endian.Big,
                               wordorder: Endian = Endian.Big,
                               **kwargs):
        return self.__write_registers(
            self.delegate.write_registers, address, value, types, byteorder, wordorder, **kwargs
        )

class ModbusTcpClient_(ModbusClient):
    def __init__(self, address: str, port: int = 502):
        parsed_url = parse_url(address)
        host = parsed_url.host
        if parsed_url.port is not None:
            port = parsed_url.port
        super().__init__(ModbusTcpClient(host, port), address, port)


class ModbusSerialClient_(ModbusClient):
    def __init__(self, port: int):
        super().__init__(ModbusSerialClient(method="rtu", port=port, baudrate=9600, stopbits=1, bytesize=8, timeout=1),
                         "Serial",
                         port)
