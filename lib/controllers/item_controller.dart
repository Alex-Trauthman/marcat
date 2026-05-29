import 'dart:io';
import 'package:flutter/material.dart';
import '../services/item_service.dart';

class ItemController extends ChangeNotifier {
  final ItemService _itemService;

  ItemController({ItemService? itemService}) : _itemService = itemService ?? ItemService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Consulta o endereço pelo CEP
  Future<Map<String, dynamic>?> fetchAddressFromCep(String cep) async {
    return await _itemService.fetchAddressFromCep(cep);
  }

  /// Cria um novo anúncio no marketplace
  Future<bool> createItem({
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
    String? cep,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
    String? complement,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemService.createItem(
        title: title,
        description: description,
        price: price,
        condition: condition,
        contactInfo: contactInfo,
        imageFile: imageFile,
        cep: cep,
        street: street,
        neighborhood: neighborhood,
        city: city,
        state: state,
        number: number,
        complement: complement,
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edita um anúncio existente
  Future<bool> updateItem({
    required String id,
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
    String? existingImageUrl,
    String? cep,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
    String? complement,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemService.updateItem(
        id: id,
        title: title,
        description: description,
        price: price,
        condition: condition,
        contactInfo: contactInfo,
        imageFile: imageFile,
        existingImageUrl: existingImageUrl,
        cep: cep,
        street: street,
        neighborhood: neighborhood,
        city: city,
        state: state,
        number: number,
        complement: complement,
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui um anúncio
  Future<bool> deleteItem(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemService.deleteItem(id);
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
