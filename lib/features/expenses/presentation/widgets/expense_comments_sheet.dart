import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/traveler_avatar.dart';
import '../../../../data/providers.dart';
import '../../../trips/domain/trip_model.dart';
import '../../domain/expense_comment_model.dart';
import '../../domain/expense_model.dart';

/// Bottom sheet displaying group comments and dispute flags for an expense.
class ExpenseCommentsSheet extends ConsumerStatefulWidget {
  final TripWithDetails trip;
  final ExpenseWithSplits expense;

  const ExpenseCommentsSheet({
    super.key,
    required this.trip,
    required this.expense,
  });

  static Future<void> show(
    BuildContext context, {
    required TripWithDetails trip,
    required ExpenseWithSplits expense,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ExpenseCommentsSheet(
        trip: trip,
        expense: expense,
      ),
    );
  }

  @override
  ConsumerState<ExpenseCommentsSheet> createState() =>
      _ExpenseCommentsSheetState();
}

class _ExpenseCommentsSheetState extends ConsumerState<ExpenseCommentsSheet> {
  final _commentController = TextEditingController();
  String? _selectedAuthorId;
  bool _isDispute = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final travelers = widget.trip.travelers;
    if (travelers.isNotEmpty) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final match = travelers.where(
          (t) =>
              t.name.toLowerCase() ==
              currentUser.displayName.trim().toLowerCase(),
        );
        _selectedAuthorId =
            match.isNotEmpty ? match.first.id : travelers.first.id;
      } else {
        _selectedAuthorId = travelers.first.id;
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final travelers = widget.trip.travelers;
      final selectedTraveler = travelers
          .where((t) => t.id == _selectedAuthorId)
          .firstOrNull;
      final authorName = selectedTraveler?.name ??
          ref.read(currentUserProvider)?.displayName ??
          'Traveler';

      await ref.read(expenseCommentRepositoryProvider).addComment(
            expenseId: widget.expense.id,
            tripId: widget.trip.id,
            authorTravelerId: selectedTraveler?.id,
            authorName: authorName,
            body: text,
            isDispute: _isDispute,
          );

      _commentController.clear();
      if (mounted) {
        setState(() => _isDispute = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsAsync = ref.watch(expenseCommentsProvider(widget.expense.id));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      key: const Key('expense_comments_sheet'),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.68,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.forum_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expense.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${Money.formatAmount(widget.expense.amountPaise, currencyCode: widget.trip.currency)} • ${widget.expense.category}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Comments list
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No comments yet',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ask a question about this bill or flag a dispute for the group.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _CommentTile(
                        comment: comment,
                        onToggleResolved: comment.isDispute
                            ? () => ref
                                .read(expenseCommentRepositoryProvider)
                                .setDisputeResolved(
                                    comment.id, !comment.isResolved)
                            : null,
                        onDelete: () => ref
                            .read(expenseCommentRepositoryProvider)
                            .deleteComment(comment.id),
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(height: 16),

            // Author & dispute toggle row
            Row(
              children: [
                if (widget.trip.travelers.isNotEmpty)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: const Key('comment_author_dropdown'),
                      initialValue: _selectedAuthorId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Commenting as',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      items: widget.trip.travelers
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                t.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedAuthorId = val),
                    ),
                  ),
                const SizedBox(width: 8),
                FilterChip(
                  key: const Key('comment_dispute_toggle'),
                  avatar: Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: _isDispute
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  label: const Text('Dispute'),
                  selected: _isDispute,
                  selectedColor: theme.colorScheme.errorContainer,
                  onSelected: (v) => setState(() => _isDispute = v),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Composer row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('comment_body_field'),
                    controller: _commentController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _isDispute
                          ? 'Describe the issue or split dispute...'
                          : 'Add a comment for the group...',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('send_comment_btn'),
                  onPressed: _isSending ? null : _submitComment,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ExpenseCommentModel comment;
  final VoidCallback? onToggleResolved;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.onToggleResolved,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOpenDispute = comment.isDispute && !comment.isResolved;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isOpenDispute
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.35)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: isOpenDispute
            ? Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.45),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TravelerAvatar(
                name: comment.authorName,
                radius: 13,
                fontSize: 9,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (comment.isDispute) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: comment.isResolved
                        ? const Color(0xFF10B981).withValues(alpha: 0.16)
                        : theme.colorScheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    comment.isResolved ? 'Resolved' : 'Dispute',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: comment.isResolved
                          ? const Color(0xFF059669)
                          : theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                DateFormat('dd MMM, HH:mm').format(comment.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.body,
            style: const TextStyle(fontSize: 13),
          ),
          if (comment.isDispute || true) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onToggleResolved != null)
                  TextButton.icon(
                    onPressed: onToggleResolved,
                    icon: Icon(
                      comment.isResolved
                          ? Icons.replay
                          : Icons.check_circle_outline,
                      size: 14,
                    ),
                    label: Text(
                      comment.isResolved ? 'Reopen dispute' : 'Mark resolved',
                      style: const TextStyle(fontSize: 11),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  tooltip: 'Delete comment',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
