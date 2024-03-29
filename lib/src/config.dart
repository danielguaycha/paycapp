import 'package:flutter/material.dart';
import 'package:paycapp/env.dart' show server;

// importante al hacer releases
const debug = false;
const buildVersion = 1.0; // incrementar segun la actualización en el server
const urlProduction = 'app.detzerg.company';

const appName = "PayApp";
const urlApi = "http://${(debug == true ? server : urlProduction )}/api";

const colors = {
    'primary': Color(0xFF1C2230),
    'accent': Color(0xFFFF9900),
    'primaryDark': Color(0xFF0E121B),
};

const Map<String, String> cobros = {
    'DIARIO': 'Diario',
    'SEMANAL': 'Semanal',
    'QUINCENAL': 'Quincenal',
    'MENSUAL': 'Mensual',
};

const Map<String, String> plazos = {
    'SEMANAL': 'Semanal',
    'QUINCENAL': 'Quincenal',
    'MENSUAL': 'Mensual',
    'MES_Y_MEDIO': 'Mes y medio',
    'DOS_MESES': 'Dos meses'
};

const Map<String, String> categorias = {
    'COMIDA'          : 'Comida',
    'COMBUSTIBLE'     : 'Combustible',
    'PAGO DE SERVICIO': 'Pago de servicio',
    'SERVICIO BASICO' : 'Servicio basico',
    'OTROS PAGOS'     : 'Otros pagos',
    'OTROS'           : 'Otros',
};

const List<int> utilidad = [10, 20, 40];

int defaultUtility = utilidad.elementAt(0);