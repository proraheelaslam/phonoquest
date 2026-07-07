#!/usr/bin/env python3
"""Add missing context.tr strings to AppTranslationMaps.es with Spanish placeholders."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP_PATH = ROOT / "lib/core/l10n/app_translation_maps.dart"

# Simple English->Spanish for common words (fallback uses title-case passthrough rules)
WORD_MAP = {
    "Add": "Agregar", "Create": "Crear", "Could": "No se pudo", "not": "no",
    "Please": "Por favor", "try": "inténtalo", "again": "de nuevo",
    "Class": "Clase", "Student": "Estudiante", "Students": "Estudiantes",
    "Assignment": "Tarea", "Message": "Mensaje", "Send": "Enviar",
    "Download": "Descargar", "Upgrade": "Mejorar plan", "Keep": "Mantener",
    "Hello": "Hola", "Password": "Contraseña", "Send": "Enviar",
    "Active": "Activo", "Module": "Módulo", "Modules": "Módulos",
    "Report": "Informe", "Reports": "Informes", "Quest": "Misión",
    "Practice": "Práctica", "Complete": "Completar", "Continue": "Continuar",
    "Mastery": "Dominio", "Accuracy": "Precisión", "Focus": "Enfoque",
    "Connect": "Conectar", "child": "niño", "Child": "Niño",
    "Teacher": "Maestro/a", "Parent": "Padre/Madre", "Plan": "Plan",
    "Premium": "Premium", "Daily": "Diario", "Goal": "Meta",
    "Reward": "Premio", "Rewards": "Premios", "Sound": "Sonido",
    "Letter": "Letra", "Letters": "Letras", "Word": "Palabra", "Words": "Palabras",
    "Forest": "Bosque", "Explorer": "Explorador", "Level": "Nivel",
    "Selected": "SELECCIONADO", "Recipients": "Destinatarios",
    "To:": "Para:", "Retry": "Reintentar", "Loading": "Cargando",
    "Error": "Error", "No": "Sin", "All": "Todo", "Activity": "Actividad",
    "Browse": "Explorar", "Archive": "Archivo", "Export": "Exportar",
    "PDF": "PDF", "Terms": "Términos", "Privacy": "Privacidad",
    "Feedback": "Comentarios", "Support": "Soporte", "Invite": "Invitar",
    "Friend": "Amigo", "Version": "Versión", "Accessibility": "Accesibilidad",
    "Font": "Fuente", "size": "tamaño", "Contrast": "Contraste",
    "Theme": "Tema", "Dark": "Oscuro", "Music": "Música", "Volume": "Volumen",
    "Mute": "Silenciar", "Notifications": "Notificaciones", "New": "Nuevas",
    "Today": "Hoy", "Help": "Ayuda", "Review": "Repasar", "Assign": "Asignar",
    "Detail": "Detalle", "History": "Historial", "Cancel": "Cancelar",
    "Select": "Seleccionar", "Choose": "Elegir", "Setup": "Configuración",
    "Professional": "Profesional", "Profile": "Perfil", "Personal": "Personal",
    "Info": "Información", "Grade": "Grado", "Name": "Nombre", "Email": "Correo",
    "Save": "Guardar", "Update": "Actualizar", "Change": "Cambiar",
    "Reading": "Lectura", "Pace": "Ritmo", "Family": "Familiar",
    "Payment": "Pago", "Billing": "Facturación", "Total": "Total",
    "Transaction": "Transacción", "Demo": "Demo", "Card": "Tarjeta",
    "Quiz": "Cuestionario", "Challenges": "Desafíos", "Submit": "Enviar",
    "Answer": "Respuesta", "Claimed": "Reclamado", "Claim": "Reclamar",
    "Progress": "Progreso", "Recent": "Reciente", "Activities": "Actividades",
    "Phonics": "Fonética", "Vowel": "Vocal", "Vowels": "Vocales", "Blend": "Combinación",
    "Blends": "Combinaciones", "Short": "Cortas", "Long": "Largas",
    "Listen": "Escuchar", "Tap": "Tocar", "Play": "Jugar", "Start": "Iniciar",
    "Ready": "Listo", "Great": "Genial", "Job": "Trabajo", "Well": "Bien",
    "done": "hecho", "Locked": "bloqueado", "Unlock": "Desbloquear",
    "Discover": "Descubrir", "Explore": "Explorar", "Journey": "Recorrido",
    "Adventure": "Aventura", "Adventures": "Aventuras", "Learning": "Aprendizaje",
    "Master": "Domina", "Mastered": "Dominadas", "Practice": "Práctica",
    "Mode": "Modo", "Chart": "Tabla", "Interactive": "Interactiva",
    "Smart": "Inteligente", "Alphabet": "Alfabeto", "Lounge": "Salón",
    "Resources": "Recursos", "Status": "Estado", "Link": "Vincular",
    "Account": "Cuenta", "Dashboard": "Panel", "Home": "Inicio",
    "Settings": "Ajustes", "Logout": "Cerrar sesión", "Login": "Iniciar sesión",
    "Sign": "Registrarse", "Up": "", "Forgot": "Olvidaste", "Welcome": "Bienvenido",
    "Back": "de nuevo", "View": "Ver", "All": "Todo", "Quick": "Rápidos",
    "Links": "Enlaces", "Classes": "Clases", "Struggling": "Con dificultades",
    "Track": "Al día", "On": "Al", "Catch-up": "Repaso", "Required": "necesario",
    "Average": "Promedio", "Metric": "Métrica", "Score": "Puntaje",
    "Action": "Acción", "Completion": "Finalización", "Specialization": "Especialización",
    "Areas": "Áreas", "of": "de", "Mascot": "Mascota", "Information": "Información",
    "Created": "Creada", "Roster": "Lista", "roster": "lista",
    "included": "incluido", "activated": "activado", "unlocked": "desbloqueado",
    "premium": "premium", "successfully": "correctamente",
    "encouragement": "ánimo", "instructions": "instrucciones",
    "confirm": "confirmar", "details": "detalles", "below": "abajo",
    "before": "antes", "sending": "enviar", "your": "tus", "students": "estudiantes",
}


def rough_es(english: str) -> str:
    """Produce reasonable Spanish; keep brand names and codes."""
    if english in WORD_MAP:
        return WORD_MAP[english]
    # Keep as-is for very short codes
    if re.match(r"^[A-Z0-9\s\.\+\-]+$", english) and len(english) < 20:
        return english  # LOGIN, PRE-K etc often kept
    # For sentences, do minimal transformation - prefix common patterns
    e = english
    replacements = [
        ("Could not ", "No se pudo "),
        ("Please ", "Por favor "),
        (" not ", " no "),
        (" and ", " y "),
        (" or ", " o "),
        (" the ", " el "),
        (" your ", " tu "),
        ("You ", "Tú "),
        ("No ", "Sin "),
        ("Add ", "Agregar "),
        ("Create ", "Crear "),
        ("Select ", "Seleccionar "),
        ("Choose ", "Elegir "),
        ("Loading", "Cargando"),
        ("Error", "Error"),
        ("Retry", "Reintentar"),
        ("Download", "Descargar"),
        ("Upgrade", "Mejorar plan"),
        ("Send", "Enviar"),
        ("Keep", "Mantener"),
        ("Hello", "Hola"),
        ("Assignment", "Tarea"),
        ("Class ", "Clase "),
        ("Student", "Estudiante"),
        ("Message", "Mensaje"),
        ("Connect", "Conectar"),
        ("Link", "Vincular"),
        ("Account", "Cuenta"),
        ("Setup Complete", "Configuración completa"),
        ("Step ", "Paso "),
        (" of ", " de "),
        ("Grade ", "Grado "),
        ("Report", "Informe"),
        ("Quest", "Misión"),
        ("Practice Mode", "Modo práctica"),
        ("Daily Quest", "Misión diaria"),
        ("Mastery Challenge", "Desafío de dominio"),
        ("Golden Ear Award", "Premio Oreja de Oro"),
        ("Active Module", "Módulo activo"),
        ("ACTIVE MODULE", "MÓDULO ACTIVO"),
        ("ACTIVE LESSON", "LECCIÓN ACTIVA"),
        ("Words Mastered", "Palabras dominadas"),
        ("Daily Goal", "Meta diaria"),
        ("View All", "Ver todo"),
        ("Claim Reward", "Reclamar premio"),
        ("Change pace", "Cambiar ritmo"),
        ("Not now", "Ahora no"),
        (" is locked", " está bloqueado"),
        (" is premium", " es premium"),
        (" downloaded successfully.", " descargado correctamente."),
        (" added to roster", " agregado a la lista"),
        (" pace activated — new adventures unlocked!", " ritmo activado — ¡nuevas aventuras desbloqueadas!"),
        (" journey is ready.", " recorrido está listo."),
        ("Not included at ", "No incluido en "),
        ("Help message sent for ", "Mensaje de ayuda enviado para "),
        ("Message sent to ", "Mensaje enviado a "),
        ("'s parent.", " del padre/madre."),
        (" Recipients", " destinatarios"),
        ("To: ", "Para: "),
        ("SELECTED", "SELECCIONADO"),
        ("Loading profile...", "Cargando perfil..."),
        ("Terms & Privacy Policy", "Términos y privacidad"),
        ("App Version", "Versión de la app"),
        ("Logout", "Cerrar sesión"),
    ]
    result = e
    for a, b in replacements:
        result = result.replace(a, b)
    return result


def collect_tr_strings() -> set[str]:
    strings = set()
    for f in (ROOT / "lib").rglob("*.dart"):
        text = f.read_text(encoding="utf-8")
        for m in re.finditer(r"context\.tr\((['\"])(.*?)\1", text, re.DOTALL):
            strings.add(m.group(2))
    return strings


def main():
    map_text = MAP_PATH.read_text(encoding="utf-8")
    existing = set(re.findall(r"'((?:\\'|[^'])*)'", map_text))
    existing.update(re.findall(r'"((?:\\"|[^"])*)"', map_text))

    all_strings = collect_tr_strings()
    missing = sorted(s for s in all_strings if s not in existing and f"'{s}'" not in map_text)

    if not missing:
        print("No missing strings")
        return

    entries = []
    for s in missing:
        es = rough_es(s)
        # escape single quotes in dart
        key = s.replace("'", "\\'")
        val = es.replace("'", "\\'")
        entries.append(f"    '{key}': '{val}',")

    # Insert before closing };
    insert = "\n    // Auto-added missing translations\n" + "\n".join(entries) + "\n"
    map_text = map_text.replace("\n  };\n}", insert + "  };\n}")
    MAP_PATH.write_text(map_text, encoding="utf-8")
    print(f"Added {len(missing)} entries to translation map")


if __name__ == "__main__":
    main()
