import 'package:flutter/material.dart';

class AgregarProductoUI extends StatelessWidget {
  const AgregarProductoUI({super.key});

  static const Color rojo = Color(0xFF9E2A1F);
  static const Color fondo = Color(0xFF1E1E1E);
  static const Color card = Color(0xFF2A2A2A);
  static const Color borde = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AGREGAR',
                      style: TextStyle(color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),

                    // Header card
                    Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: rojo,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.change_history,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _input('Nombre del Producto', 'Ej. Vidrio Templado'),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _input('Código', 'VT001')),
                        const SizedBox(width: 12),
                        Expanded(child: _dropdown()),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: _input('Cantidad', '1')),
                        const SizedBox(width: 12),
                        Expanded(child: _input('Precio Unit.', 'S/ 0.00')),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _input('Grosor (opcional)', ''),

                    const SizedBox(height: 20),

                    const Text(
                      'Imagen del Producto',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _imageButton(Icons.upload, 'Desde galería'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _imageButton(Icons.camera_alt, 'Tomar foto'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _input('Descripción', '', maxLines: 3),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _actionButton('Limpiar', Colors.grey.shade700),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _actionButton('Agregar', rojo)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets reutilizables ----------

  static Widget _input(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: card,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borde),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _dropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borde),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Seleccionar',
              dropdownColor: card,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: 'Seleccionar',
                  child: Text('Seleccionar'),
                ),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  static Widget _imageButton(IconData icon, String text) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rojo),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: rojo),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: rojo, fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _actionButton(String text, Color color) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    final color = active ? AgregarProductoUI.rojo : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
