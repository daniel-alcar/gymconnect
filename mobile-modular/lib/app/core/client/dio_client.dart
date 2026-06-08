import 'package:dio/dio.dart';

import 'package:gymconnect/app/core/constants/app_constants.dart';
import 'package:gymconnect/app/core/errors/app_exception.dart';
import 'package:gymconnect/app/core/storage/storage_service.dart';

/// Centraliza o Dio com:
/// - baseUrl e timeouts;
/// - Interceptor que injeta `Authorization: Bearer <token>`;
/// - Tratamento de erros padronizado em [AppException];
/// - Callback de logout automático em 401/403.
class DioClient {
  final Dio dio;
  final StorageService _storage;

  /// Disparado quando o backend responde 401/403 (token inválido/expirado).
  void Function()? onUnauthorized;

  DioClient(this._storage)
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            // Tratamos os status manualmente para extrair a mensagem.
            validateStatus: (status) => status != null && status < 500,
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.lerToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          final status = response.statusCode ?? 0;
          if (status == 401 || status == 403) {
            onUnauthorized?.call();
          }
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  /// Extrai a mensagem amigável de uma resposta de erro do backend.
  ///
  /// O backend pode retornar `{ "mensagem": "..." }`, texto simples,
  /// ou corpo vazio (apenas status).
  AppException tratarResposta(Response response) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    String mensagem;

    if (data is Map && data['mensagem'] != null) {
      mensagem = data['mensagem'].toString();
    } else if (data is String && data.trim().isNotEmpty) {
      mensagem = data;
    } else {
      mensagem = _mensagemPorStatus(status);
    }
    return AppException(mensagem, statusCode: status);
  }

  AppException tratarDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const AppException(
        'Tempo de conexão esgotado. Verifique o servidor.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AppException(
        'Não foi possível conectar ao servidor. Verifique a URL/rede.',
      );
    }
    if (e.response != null) {
      return tratarResposta(e.response!);
    }
    return AppException(e.message ?? 'Erro inesperado de rede.');
  }

  String _mensagemPorStatus(int status) {
    switch (status) {
      case 400:
        return 'Requisição inválida.';
      case 401:
        return 'Sessão expirada. Faça login novamente.';
      case 403:
        return 'Você não tem permissão para esta ação.';
      case 404:
        return 'Recurso não encontrado.';
      case 502:
        return 'Falha ao comunicar com a IA. Tente novamente.';
      default:
        return 'Erro: $status';
    }
  }

  bool isSucesso(Response response) {
    final status = response.statusCode ?? 0;
    return status >= 200 && status < 300;
  }

  /// Normaliza qualquer erro lançado nas chamadas em uma [AppException].
  ///
  /// Reusado por todos os services para evitar repetição de try/catch.
  AppException normalize(Object error) {
    if (error is AppException) return error;
    if (error is DioException) return tratarDioError(error);
    return AppException(error.toString());
  }
}
