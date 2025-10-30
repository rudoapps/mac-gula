import Foundation
import Sparkle

/// Servicio que gestiona las actualizaciones automáticas usando Sparkle
@Observable
class SparkleUpdateService {
    static let shared = SparkleUpdateService()

    private var updaterController: SPUStandardUpdaterController?

    /// URL del appcast que contiene las actualizaciones
    /// En Debug y Release apunta al mismo repositorio de releases
    private let appcastURL: String = {
        #if DEBUG
        print("🔧 [DEBUG] Configurando Sparkle para Debug")
        #endif
        return "https://raw.githubusercontent.com/rudoapps/mac-gula-releases/main/appcast.xml"
    }()

    init() {
        setupUpdater()

        #if DEBUG
        // En Debug, verificar actualizaciones al inicio después de 3 segundos
        checkForUpdatesOnLaunch()
        #endif
    }

    // MARK: - Setup

    private func setupUpdater() {
        #if DEBUG
        print("🔧 [DEBUG] Iniciando configuración de Sparkle...")
        print("🔧 [DEBUG] Usando appcast URL: \(appcastURL)")
        #endif

        // Crear el controlador de Sparkle
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        // Configurar la URL del appcast
        if let updater = updaterController?.updater {
            updater.setFeedURL(URL(string: appcastURL))

            #if DEBUG
            print("🔧 [DEBUG] Sparkle configurado correctamente")
            print("🔧 [DEBUG] Verificación automática: \(updater.automaticallyChecksForUpdates)")
            #endif
        } else {
            #if DEBUG
            print("❌ [DEBUG] Error: No se pudo obtener el updater de Sparkle")
            #endif
        }
    }

    /// Verifica actualizaciones automáticamente al iniciar la app (solo en Debug)
    private func checkForUpdatesOnLaunch() {
        #if DEBUG
        print("🔧 [DEBUG] Programando verificación automática al inicio...")

        // Esperar 3 segundos para que la app termine de cargar
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            print("🔧 [DEBUG] Verificando actualizaciones automáticamente...")
            self?.checkForUpdates(nil)
        }
        #endif
    }

    // MARK: - Public Methods

    /// Verifica manualmente si hay actualizaciones disponibles
    /// - Parameter sender: El objeto que inicia la verificación (puede ser nil)
    func checkForUpdates(_ sender: Any? = nil) {
        #if DEBUG
        print("🔧 [DEBUG] Verificando actualizaciones manualmente...")
        #endif

        updaterController?.checkForUpdates(sender)
    }

    /// Indica si el updater está configurado y listo
    var isConfigured: Bool {
        updaterController != nil
    }

    /// Obtiene el updater para configuraciones avanzadas
    var updater: SPUUpdater? {
        updaterController?.updater
    }
}
