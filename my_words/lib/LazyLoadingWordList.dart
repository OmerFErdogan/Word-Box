import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/words_model.dart';
import 'widgets/flashcard.dart';

class LazyLoadingWordList extends StatefulWidget {
  final WordsModel wordsModel;
  final int pageSize;

  const LazyLoadingWordList({
    Key? key,
    required this.wordsModel,
    this.pageSize = 20,
  }) : super(key: key);

  @override
  _LazyLoadingWordListState createState() => _LazyLoadingWordListState();
}

class _LazyLoadingWordListState extends State<LazyLoadingWordList> {
  final ScrollController _scrollController = ScrollController();
  List<Word> _loadedWords = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreWords = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMoreWords();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreWords() async {
    if (_isLoading || !_hasMoreWords) return;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final newWords =
          await widget.wordsModel.getPagedWords(_currentPage, widget.pageSize);

      if (mounted) {
        setState(() {
          if (newWords.isEmpty) {
            _hasMoreWords = false;
          } else {
            _loadedWords.addAll(newWords);
            _currentPage++;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'Error loading words. Please try again.';
        });
      }
      print('Error loading words: $e');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreWords();
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isError = false;
                _loadMoreWords();
              });
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _loadedWords.length + (_hasMoreWords ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _loadedWords.length) {
          return WordCard(
            word: _loadedWords[index],
            index: index + 1,
            onFavoriteChanged: (isFavorite) {
              widget.wordsModel.toggleFavorite(_loadedWords[index]);
            },
          );
        } else if (_isLoading) {
          return _buildLoadingWidget();
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return _buildErrorWidget();
    }

    if (_loadedWords.isEmpty && _isLoading) {
      return _buildLoadingWidget();
    }

    if (_loadedWords.isEmpty && !_isLoading) {
      return Center(child: Text('No words found. Try adding some!'));
    }

    return Stack(
      children: [
        _buildWordList(),
        if (_isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 5,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          ),
      ],
    );
  }
}
