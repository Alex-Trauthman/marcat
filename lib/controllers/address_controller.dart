import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressController extends ChangeNotifier {
  final AddressService _addressService;

  AddressController({AddressService? addressService})
      : _addressService = addressService ?? AddressService();

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Busca todos os endereços do usuário
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _addressService.fetchAddresses();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo endereço
  Future<bool> addAddress({
    required String userId,
    String? alias,
    required String cep,
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = Address(
        userId: userId,
        alias: alias,
        cep: cep,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
      );

      final savedAddress = await _addressService.createAddress(newAddress);
      _addresses.add(savedAddress);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove um endereço existente
  Future<bool> removeAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _addressService.deleteAddress(id);
      _addresses.removeWhere((address) => address.id == id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
