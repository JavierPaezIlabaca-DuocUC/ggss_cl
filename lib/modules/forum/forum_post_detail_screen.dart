// ============================================================
// forum_post_detail_screen.dart
// Pantalla de detalle de una publicación del foro.
// Muestra el post completo, sus comentarios y permite
// agregar o eliminar comentarios.
// Los enlaces externos en el contenido activan ExternalLinkDialog.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../models/forum_comment_model.dart';
import '../../models/forum_post_model.dart';
import '../../shared/widgets/external_link_dialog.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../auth/auth_providers.dart';
import 'forum_providers.dart';

/// Pantalla de detalle de una publicación del foro
class ForumPostDetailScreen extends ConsumerStatefulWidget {
  final ForumPostModel post;

  const ForumPostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<ForumPostDetailScreen> createState() =>
      _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState
    extends ConsumerState<ForumPostDetailScreen> {
  // Controlador del campo de texto para nuevo comentario
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Enviar nuevo comentario
  // ----------------------------------------------------------

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSendingComment = true);

    final comment = ForumCommentModel(
      id: '',
      postId: widget.post.id,
      content: text,
      userId: currentUser.id,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(forumCommentsNotifierProvider(widget.post.id).notifier)
          .addComment(comment);
      _commentController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  // ----------------------------------------------------------
  // Confirmar y eliminar post
  // ----------------------------------------------------------

  Future<void> _confirmDeletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.forumDeletePost),
        content: const Text(AppStrings.forumDeletePostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(forumPostsNotifierProvider.notifier)
          .deletePost(widget.post.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
        );
      }
    }
  }

  // ----------------------------------------------------------
  // Confirmar y eliminar comentario
  // ----------------------------------------------------------

  Future<void> _confirmDeleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.forumDeleteComment),
        content: const Text(AppStrings.forumDeleteCommentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(forumCommentsNotifierProvider(widget.post.id).notifier)
          .deleteComment(commentId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.errorGeneral)),
        );
      }
    }
  }

  // ----------------------------------------------------------
  // Construcción principal
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final commentsAsync =
        ref.watch(forumCommentsNotifierProvider(widget.post.id));
    final theme = Theme.of(context);
    final isAuthor = currentUser?.id == widget.post.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicación'),
        actions: [
          // Botón eliminar post: solo visible para el autor
          if (isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: AppStrings.forumDeletePost,
              onPressed: _confirmDeletePost,
            ),
        ],
      ),
      body: Column(
        children: [
          // --------------------------------------------------
          // Área scrolleable: post + comentarios
          // --------------------------------------------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              children: [
                // Post: título
                Text(
                  widget.post.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingSm),

                // Post: categoría (si existe)
                if (widget.post.category != null &&
                    widget.post.category!.isNotEmpty) ...[
                  Chip(
                    label: Text(
                      widget.post.category!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                ],

                // Post: autor y fecha
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: AppDimensions.iconSm,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      widget.post.authorAlias ??
                          widget.post.authorName ??
                          AppStrings.forumAnonymous,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      '·',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Text(
                      timeago.format(widget.post.createdAt, locale: 'es'),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                const Divider(height: AppDimensions.spacingXl),

                // Post: contenido con URLs detectadas y clickeables
                _LinkifiedText(
                  text: widget.post.content,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // Encabezado de la sección de comentarios
                Text(
                  AppStrings.forumComments,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingSm),

                // --------------------------------------------------
                // Lista de comentarios
                // --------------------------------------------------
                commentsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingLg,
                    ),
                    child: LoadingIndicator(),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingMd,
                    ),
                    child: Text(
                      AppStrings.errorGeneral,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.spacingMd,
                        ),
                        child: Text(
                          AppStrings.forumNoComments,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }
                    return Column(
                      children: comments
                          .map(
                            (c) => _CommentItem(
                              comment: c,
                              isAuthor: currentUser?.id == c.userId,
                              onDelete: () => _confirmDeleteComment(c.id),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                // Espacio al final para que el último comentario
                // no quede tapado por el input
                const SizedBox(height: AppDimensions.spacingMd),
              ],
            ),
          ),

          // --------------------------------------------------
          // Campo de texto para nuevo comentario (fijo al fondo)
          // --------------------------------------------------
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
              AppDimensions.spacingMd,
              AppDimensions.spacingMd +
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: AppStrings.forumCommentHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                        vertical: AppDimensions.spacingSm,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendComment(),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                // Botón enviar
                _isSendingComment
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton.filled(
                        icon: const Icon(Icons.send_outlined),
                        onPressed: _sendComment,
                        tooltip: AppStrings.forumComment,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget interno: ítem de comentario
// ============================================================

class _CommentItem extends StatelessWidget {
  final ForumCommentModel comment;
  final bool isAuthor;
  final VoidCallback onDelete;

  const _CommentItem({
    required this.comment,
    required this.isAuthor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del comentarista
          CircleAvatar(
            radius: 16,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              (comment.authorAlias ??
                      comment.authorName ??
                      AppStrings.forumAnonymous)
                  .substring(0, 1)
                  .toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingSm),

          // Contenido del comentario
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Autor y tiempo
                  Row(
                    children: [
                      Text(
                        comment.authorAlias ??
                            comment.authorName ??
                            AppStrings.forumAnonymous,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Text(
                        timeago.format(comment.createdAt, locale: 'es'),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      // Botón eliminar: solo visible para el autor
                      if (isAuthor)
                        GestureDetector(
                          onTap: onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            size: AppDimensions.iconSm,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  // Contenido del comentario con URLs detectadas
                  _LinkifiedText(
                    text: comment.content,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget interno: texto con URLs detectadas y clickeables.
// Las URLs abren ExternalLinkDialog antes de navegar al navegador.
// ============================================================

class _LinkifiedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _LinkifiedText({required this.text, this.style});

  static final _urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urlStyle = (style ?? theme.textTheme.bodyMedium)?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in _urlRegex.allMatches(text)) {
      // Segmento de texto plano antes de la URL
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      // Segmento de URL clickeable
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: urlStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => ExternalLinkOpener.open(context, url),
      ));

      lastIndex = match.end;
    }

    // Texto restante después de la última URL
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
