import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/item_controller.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    // Substitui ponto por vírgula visualmente para o usuário brasileiro
    String newText = newValue.text.replaceAll('.', ',');
    
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedCondition = 'Usado - Em bom estado';
  final List<String> _conditions = [
    'Novo',
    'Usado - Como novo',
    'Usado - Em bom estado',
    'Usado - Com marcas de uso',
    'Para Doação'
  ];

  bool _isFree = false;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione pelo menos uma foto do item.')),
      );
      return;
    }

    final itemController = context.read<ItemController>();
    final double price = _isFree ? 0.0 : (double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0);

    final success = await itemController.createItem(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      condition: _selectedCondition,
      contactInfo: _contactController.text.trim(),
      imageFile: _imageFile,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anúncio publicado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${itemController.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ItemController, bool>((ctrl) => ctrl.isLoading);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: const Text('Novo Anúncio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker Area
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      image: _imageFile != null
                          ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Adicionar fotos', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'O que você está vendendo/doando?',
                          hintText: 'Ex: Bicicleta Caloi 10',
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Título é obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCondition,
                        decoration: const InputDecoration(labelText: 'Condição do item'),
                        items: _conditions.map((String condition) {
                          return DropdownMenuItem<String>(
                            value: condition,
                            child: Text(condition),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCondition = newValue!;
                            if (_selectedCondition == 'Para Doação') {
                              _isFree = true;
                              _priceController.clear();
                            } else {
                              _isFree = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição detalhada',
                          hintText: 'Descreva o estado, tempo de uso, etc.',
                        ),
                        maxLines: 3,
                        validator: (value) => value!.trim().isEmpty ? 'Descrição é obrigatória' : null,
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text('É uma doação (Grátis)'),
                        value: _isFree,
                        activeColor: Colors.black87,
                        onChanged: (bool? value) {
                          setState(() {
                            _isFree = value ?? false;
                            if (_isFree) {
                              _priceController.clear();
                              _selectedCondition = 'Para Doação';
                            } else {
                               if(_selectedCondition == 'Para Doação') {
                                 _selectedCondition = 'Usado - Em bom estado';
                               }
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (!_isFree) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Preço (R\$)',
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            CurrencyInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Preço é obrigatório';
                            if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '.')) == null) {
                              return 'Insira um valor válido';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone para contato',
                          hintText: '(11) 99999-9999',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.trim().isEmpty ? 'Contato é obrigatório' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publicar Anúncio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
