import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/services/digi_service.dart';

class AgregarProductoUI extends StatefulWidget {
  final VoidCallback onProductoAgregado;

  const AgregarProductoUI({super.key, required this.onProductoAgregado});

  @override
  State<AgregarProductoUI> createState() => _AgregarProductoUIState();
}

class _AgregarProductoUIState extends State<AgregarProductoUI> {
  late TextEditingController _nombreController;
  late TextEditingController _codigoController;
  late TextEditingController _cantidadController;
  late TextEditingController _precioController;
  late TextEditingController _grosorController;
  late TextEditingController _descripcionController;

  String? _categoriaSeleccionada;
  File? _imagenSeleccionada;
  bool _cargando = false;

  final DigiService _digiService = DigiService();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _codigoController = TextEditingController();
    _cantidadController = TextEditingController(text: '1');
    _precioController = TextEditingController();
    _grosorController = TextEditingController();
    _descripcionController = TextEditingController();
    _categoriaSeleccionada = 'Seleccionar';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _grosorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imagenSeleccionada = File(result.files.first.path!);
      });
    }
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _codigoController.clear();
    _cantidadController.text = '1';
    _precioController.clear();
    _grosorController.clear();
    _descripcionController.clear();
    setState(() {
      _categoriaSeleccionada = 'Seleccionar';
      _imagenSeleccionada = null;
    });
  }

  Future<void> _agregarProducto() async {
    if (_nombreController.text.isEmpty) {
      _snack("Ingresa el nombre del producto");
      return;
    }

    if (_precioController.text.isEmpty) {
      _snack("Ingresa el precio");
      return;
    }

    setState(() => _cargando = true);

    try {
      await _digiService.crearProducto(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.isEmpty
            ? null
            : _descripcionController.text,
        categoria: _categoriaSeleccionada == 'Seleccionar'
            ? null
            : _categoriaSeleccionada,
        precio: double.tryParse(_precioController.text) ?? 0,
        grosor: _grosorController.text.isEmpty ? null : _grosorController.text,
        cantidad: int.tryParse(_cantidadController.text) ?? 1,
        imagenFile: _imagenSeleccionada,
      );

      _limpiarFormulario();
      widget.onProductoAgregado();
      _snack("Producto agregado correctamente");
    } catch (e) {
      _snack("Error al agregar producto");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AGREGAR',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // CARD PRINCIPAL
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // HEADER ROJO CURVO
                    Container(
                      height: 95,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9E2A1F),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                          bottomLeft: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/rojo.png',
                          height: 45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Nombre del Producto"),
                          _input(_nombreController, "Ej. Vidrio Templado"),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label("Código"),
                                    _input(_codigoController, "VT001"),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _dropdown()),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label("Cantidad"),
                                    _input(_cantidadController, "1"),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _label("Precio Unit."),
                                    _input(_precioController, "S/ 0.00"),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          _label("Grosor (opcional)"),
                          _input(_grosorController, ""),

                          const SizedBox(height: 18),

                          const Text(
                            "Imagen del Producto",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _botonImagen(
                                  icon: Icons.image_outlined,
                                  texto: "Desde galería",
                                  onTap: _seleccionarImagen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _botonImagen(
                                  icon: Icons.camera_alt_outlined,
                                  texto: "Tomar foto",
                                  onTap: _seleccionarImagen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _label("Descripción"),
                          _input(_descripcionController, "", maxLines: 3),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: _botonSecundario(
                                  "Limpiar",
                                  _limpiarFormulario,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _botonPrincipal(
                                  "Agregar",
                                  _agregarProducto,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F6F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8FC3DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8FC3DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5AA9CC), width: 2),
        ),
      ),
    );
  }

  Widget _dropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Categoría"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF8FC3DD)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categoriaSeleccionada,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'Seleccionar',
                  child: Text('Seleccionar'),
                ),
                DropdownMenuItem(value: 'Vidrio', child: Text('Vidrio')),
                DropdownMenuItem(value: 'Aluminio', child: Text('Aluminio')),
                DropdownMenuItem(
                  value: 'Accesorios',
                  child: Text('Accesorios'),
                ),
              ],
              onChanged: (v) => setState(() => _categoriaSeleccionada = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonImagen({
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9E2A1F)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.grey[700]),
            const SizedBox(height: 6),
            Text(texto, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _botonPrincipal(String texto, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _cargando ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9E2A1F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _cargando
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                texto,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _botonSecundario(String texto, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
